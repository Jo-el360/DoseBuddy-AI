import logging
from a2wsgi import ASGIMiddleware
from wsgiref.simple_server import make_server
from app.main import app
from app.core.config import settings

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
logger = logging.getLogger("run_server")

wsgi_app = ASGIMiddleware(app)

if __name__ == "__main__":
    host = "0.0.0.0"
    port = settings.PORT
    print(f"\n========================================================")
    print(f"[+] DoseBuddy AI FastAPI Backend Server Running!")
    print(f"[*] Base URL: http://localhost:{port}")
    print(f"[*] Interactive Swagger API Docs: http://localhost:{port}/docs")
    print(f"[*] ReDoc Documentation: http://localhost:{port}/redoc")
    print(f"[*] Health Check Endpoint: http://localhost:{port}/api/v1/health")
    print(f"========================================================\n")
    
    server = make_server(host, port, wsgi_app)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping server...")
