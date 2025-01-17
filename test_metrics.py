import pytest
from prometheus_client import Info

def test_metrics_init():
    """Test basic metrics initialization"""
    info = Info("test_metric", "Test metric help")
    assert info._name == "test_metric"
    assert info._documentation == "Test metric help"
