from app.seguranca import conferir_senha, gerar_hash


def test_hash_de_senha():
    senha = "senha-segura"
    senha_hash = gerar_hash(senha)
    assert senha_hash != senha
    assert conferir_senha(senha, senha_hash)
    assert not conferir_senha("senha-errada", senha_hash)
