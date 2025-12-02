"""
TechEX Application Tests
"""
import pytest
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app, DEFAULT_PARCELS

@pytest.fixture
def client():
    """Create a test client for the Flask application"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_check(client):
    """Test the health check endpoint"""
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'
    assert 'version' in data
    assert 'timestamp' in data

def test_readiness_check(client):
    """Test the readiness check endpoint"""
    response = client.get('/ready')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'ready'

def test_index_page(client):
    """Test the index page loads successfully"""
    response = client.get('/')
    assert response.status_code == 200

def test_list_parcels(client):
    """Test the list parcels page"""
    response = client.get('/parcels')
    assert response.status_code == 200

def test_statistics_page(client):
    """Test the statistics page"""
    response = client.get('/statistics')
    assert response.status_code == 200

def test_api_parcels(client):
    """Test the API endpoint for parcels"""
    response = client.get('/api/parcels')
    assert response.status_code == 200
    data = response.get_json()
    assert isinstance(data, list)

def test_add_parcel_page(client):
    """Test the add parcel page loads"""
    response = client.get('/add_parcel')
    assert response.status_code == 200

def test_default_data_exists():
    """Test that default parcel data exists"""
    assert len(DEFAULT_PARCELS) > 0
    
    # Check first parcel has required fields
    first_parcel = DEFAULT_PARCELS[0]
    required_fields = ['id', 'tracking_number', 'sender', 'receiver', 
                       'origin', 'destination', 'status', 'cost', 
                       'weight', 'dispatch_date']
    
    for field in required_fields:
        assert field in first_parcel, f"Missing field: {field}"

