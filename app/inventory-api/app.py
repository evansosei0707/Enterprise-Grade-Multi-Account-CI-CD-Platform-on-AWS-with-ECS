"""
Inventory Management API - ECS Fargate Application
A stateless RESTful API for managing inventory items.
Backed by DynamoDB for persistent storage.
"""

import os
import json
import uuid
from datetime import datetime
from flask import Flask, jsonify, request
import boto3
from botocore.exceptions import ClientError

app = Flask(__name__)

# Configuration from environment variables
ENVIRONMENT = os.getenv('ENVIRONMENT', 'dev')
AWS_REGION = os.getenv('AWS_REGION', 'us-east-1')
DYNAMODB_TABLE = os.getenv('DYNAMODB_TABLE', f'inventory-items-{ENVIRONMENT}')

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE)


# =============================================================================
# Health Check Endpoint
# =============================================================================

@app.route('/health', methods=['GET'])
def health_check():
    """
    Health check endpoint for ALB target group.
    Returns 200 if the service is healthy.
    """
    return jsonify({
        'status': 'healthy',
        'service': 'inventory-api',
        'environment': ENVIRONMENT,
        'timestamp': datetime.utcnow().isoformat()
    }), 200


# =============================================================================
# Items Endpoints
# =============================================================================

@app.route('/items', methods=['GET'])
def list_items():
    """
    List all inventory items.
    Returns a list of items from DynamoDB.
    """
    try:
        response = table.scan()
        items = response.get('Items', [])
        
        return jsonify({
            'items': items,
            'count': len(items)
        }), 200
        
    except ClientError as e:
        app.logger.error(f"DynamoDB scan error: {e}")
        return jsonify({
            'error': 'Failed to retrieve items',
            'message': str(e)
        }), 500


@app.route('/items', methods=['POST'])
def create_item():
    """
    Create a new inventory item.
    Expects JSON body with 'name' and optional 'quantity', 'description'.
    """
    try:
        data = request.get_json()
        
        if not data or 'name' not in data:
            return jsonify({
                'error': 'Validation error',
                'message': 'Item name is required'
            }), 400
        
        # Generate unique ID and timestamp
        item_id = str(uuid.uuid4())
        timestamp = datetime.utcnow().isoformat()
        
        # Build item object
        item = {
            'id': item_id,
            'name': data['name'],
            'quantity': data.get('quantity', 0),
            'description': data.get('description', ''),
            'created_at': timestamp,
            'updated_at': timestamp
        }
        
        # Store in DynamoDB
        table.put_item(Item=item)
        
        return jsonify({
            'message': 'Item created successfully',
            'item': item
        }), 201
        
    except ClientError as e:
        app.logger.error(f"DynamoDB put error: {e}")
        return jsonify({
            'error': 'Failed to create item',
            'message': str(e)
        }), 500


@app.route('/items/<item_id>', methods=['GET'])
def get_item(item_id):
    """
    Get a specific inventory item by ID.
    """
    try:
        response = table.get_item(Key={'id': item_id})
        
        if 'Item' not in response:
            return jsonify({
                'error': 'Not found',
                'message': f'Item with ID {item_id} not found'
            }), 404
        
        return jsonify({
            'item': response['Item']
        }), 200
        
    except ClientError as e:
        app.logger.error(f"DynamoDB get error: {e}")
        return jsonify({
            'error': 'Failed to retrieve item',
            'message': str(e)
        }), 500


@app.route('/items/<item_id>', methods=['PUT'])
def update_item(item_id):
    """
    Update an existing inventory item.
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'error': 'Validation error',
                'message': 'Request body is required'
            }), 400
        
        # Build update expression
        update_expr = 'SET updated_at = :updated_at'
        expr_values = {':updated_at': datetime.utcnow().isoformat()}
        
        if 'name' in data:
            update_expr += ', #n = :name'
            expr_values[':name'] = data['name']
        
        if 'quantity' in data:
            update_expr += ', quantity = :quantity'
            expr_values[':quantity'] = data['quantity']
        
        if 'description' in data:
            update_expr += ', description = :description'
            expr_values[':description'] = data['description']
        
        # Update in DynamoDB
        response = table.update_item(
            Key={'id': item_id},
            UpdateExpression=update_expr,
            ExpressionAttributeValues=expr_values,
            ExpressionAttributeNames={'#n': 'name'} if 'name' in data else {},
            ReturnValues='ALL_NEW',
            ConditionExpression='attribute_exists(id)'
        )
        
        return jsonify({
            'message': 'Item updated successfully',
            'item': response['Attributes']
        }), 200
        
    except ClientError as e:
        if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
            return jsonify({
                'error': 'Not found',
                'message': f'Item with ID {item_id} not found'
            }), 404
        app.logger.error(f"DynamoDB update error: {e}")
        return jsonify({
            'error': 'Failed to update item',
            'message': str(e)
        }), 500


@app.route('/items/<item_id>', methods=['DELETE'])
def delete_item(item_id):
    """
    Delete an inventory item.
    """
    try:
        # Check if item exists first
        response = table.delete_item(
            Key={'id': item_id},
            ConditionExpression='attribute_exists(id)',
            ReturnValues='ALL_OLD'
        )
        
        return jsonify({
            'message': 'Item deleted successfully',
            'item': response.get('Attributes', {})
        }), 200
        
    except ClientError as e:
        if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
            return jsonify({
                'error': 'Not found',
                'message': f'Item with ID {item_id} not found'
            }), 404
        app.logger.error(f"DynamoDB delete error: {e}")
        return jsonify({
            'error': 'Failed to delete item',
            'message': str(e)
        }), 500


# =============================================================================
# Root Endpoint
# =============================================================================

@app.route('/', methods=['GET'])
def root():
    """
    Root endpoint - API information.
    """
    return jsonify({
        'service': 'Inventory Management API',
        'version': '1.0.0',
        'environment': ENVIRONMENT,
        'endpoints': {
            'health': 'GET /health',
            'list_items': 'GET /items',
            'create_item': 'POST /items',
            'get_item': 'GET /items/{id}',
            'update_item': 'PUT /items/{id}',
            'delete_item': 'DELETE /items/{id}'
        }
    }), 200


# =============================================================================
# Application Entry Point
# =============================================================================

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8080))
    debug = os.getenv('FLASK_DEBUG', 'false').lower() == 'true'
    
    app.run(host='0.0.0.0', port=port, debug=debug)
