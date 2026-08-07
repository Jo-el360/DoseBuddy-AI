import warnings
import pytest

@pytest.fixture(autouse=True)
def ignore_deprecations():
    warnings.filterwarnings("ignore", category=DeprecationWarning)
    warnings.filterwarnings("ignore", message=".*starlette.testclient.*")
