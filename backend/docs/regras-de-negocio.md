# Regras de negócio — Meu Cinema Organizado

- Um filme possui título, diretor, ano, gênero, duração e situação de assistido.
- Título e ano são usados para impedir duplicidade no catálogo.
- A situação `assistido` pode ser alterada sem afetar os demais dados.
- Filmes podem ser consultados, cadastrados, atualizados e excluídos por usuários autenticados.
- A situação de assistido não representa disponibilidade para empréstimo.
- Usuários são identificados por e-mail único.
- Senhas nunca são armazenadas em texto puro: apenas o hash bcrypt é persistido.
