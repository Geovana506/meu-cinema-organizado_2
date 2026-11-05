import os

# Variáveis definidas antes da importação dos módulos que carregam a configuração.
os.environ.setdefault("SECRET_KEY", "chave-de-testes-com-mais-de-trinta-e-dois-caracteres")
os.environ.setdefault("DATABASE_URL", "sqlite:///./test_meu_cinema.db")
