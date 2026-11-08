# Minhas Tarefas

Aplicativo **Flutter** de lista de tarefas (To-Do List) com **login de usuário** e **CRUD completo**, salvando tudo em um banco **SQLite** local.

Projeto desenvolvido para a disciplina de Desenvolvimento Mobile — Fatec.

**Aluno:** Fabrício Andrade Cardoso de Araújo

---

## Descrição

Cada pessoa cria sua conta, faz login e gerencia a própria lista de tarefas: cria, vê, edita, marca como concluída e exclui. Cada tarefa pode ter uma **data de entrega**, e o app destaca com cores as tarefas vencidas, as que vencem hoje e as que estão perto do prazo. As tarefas de um usuário não aparecem para outro. Os dados ficam salvos no aparelho, então nada se perde ao fechar o app.

## Funcionalidades principais

| Funcionalidade | Onde está |
|---|---|
| Cadastro de usuário (nome, e-mail, senha, confirmar senha) | `screens/register_screen.dart` |
| Login com e-mail e senha | `screens/login_screen.dart` |
| Logout (botão no topo da Home) | `screens/home_screen.dart` |
| Proteção de telas (Home e Formulário só com login) | `routes.dart` |
| **C**riar tarefa | `screens/tarefa_form_screen.dart` |
| **L**istar tarefas do usuário | `screens/home_screen.dart` |
| **A**tualizar tarefa (editar e marcar como concluída) | `tarefa_form_screen.dart` / `home_screen.dart` |
| **D**eletar tarefa (com confirmação) | `screens/home_screen.dart` |
| Data de entrega com calendário | `screens/tarefa_form_screen.dart` |
| Aviso de prazo por cor (vencida, vence hoje, perto do prazo, em dia) | `widgets/tarefa_card.dart` + `models/tarefa.dart` |
| Alerta no topo com o total de tarefas atrasadas ou perto do prazo | `screens/home_screen.dart` |
| Validação de formulários | `utils/validadores.dart` |
| Tratamento de erros (login inválido, campos vazios, e-mail já cadastrado) | `services/auth_service.dart` + telas |

## Tecnologias utilizadas

- **Flutter** e **Dart**
- **SQLite** com o pacote [`sqflite`](https://pub.dev/packages/sqflite)
- [`sqflite_common_ffi`](https://pub.dev/packages/sqflite_common_ffi) — para rodar o SQLite no Windows/Linux
- [`path`](https://pub.dev/packages/path) — monta o caminho do arquivo do banco
- [`crypto`](https://pub.dev/packages/crypto) — gera o hash SHA-256 das senhas
- `flutter_localizations` — deixa o calendário (DatePicker) em português
- Rotas nomeadas do Flutter (`onGenerateRoute`)

## Estrutura do projeto

```
lib/
├── main.dart                     # Inicia o app e configura o SQLite no desktop
├── routes.dart                   # Rotas nomeadas + proteção de telas
├── models/
│   ├── usuario.dart              # Modelo do usuário (toMap / fromMap)
│   └── tarefa.dart               # Modelo da tarefa (toMap / fromMap / copyWith)
├── services/
│   ├── auth_service.dart         # Cadastro, login, logout e sessão
│   └── database_service.dart     # Criação das tabelas e CRUD no SQLite
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart          # Lista de tarefas
│   └── tarefa_form_screen.dart   # Criar / editar tarefa
├── widgets/
│   ├── campo_texto.dart          # Campo de formulário reutilizável
│   └── tarefa_card.dart          # Card de uma tarefa na lista
└── utils/
    ├── validadores.dart          # Regras de validação dos campos
    └── datas.dart                # Formatação de datas (dd/mm/aaaa)
test/
└── widget_test.dart              # Testes de validação, modelo e tela de login
```

A lógica fica separada em camadas: **telas** (UI) só cuidam da interface, **services** fazem o acesso ao banco e a autenticação, e **models** representam os dados.

## Como executar

Pré-requisito: [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (`flutter doctor` sem erros).

```bash
# 1. Clonar o repositório
git clone https://github.com/Fabricio7219/minhas_tarefas.git
cd minhas_tarefas

# 2. Gerar as pastas das plataformas (android, windows...) se não existirem
flutter create . --project-name minhas_tarefas

# 3. Baixar as dependências
flutter pub get

# 4. Rodar (emulador Android aberto ou celular conectado)
flutter run
```

- **Android (recomendado):** abra um emulador ou conecte o celular e rode `flutter run`.
- **Windows:** `flutter run -d windows`.
- **Linux:** instale antes `sudo apt install libsqlite3-dev` e rode `flutter run -d linux`.
- **Web não é suportada**, porque o SQLite (`sqflite`) não roda no navegador.

Para rodar os testes: `flutter test`

## Autenticação

A autenticação é **local**, feita com o próprio SQLite (sem Firebase):

1. **Cadastro:** o app verifica se o e-mail já existe. Se não existir, salva o usuário na tabela `usuarios`. A senha **não é salva em texto puro**: é salvo só o seu **hash SHA-256**.
2. **Login:** o app busca o usuário pelo e-mail e compara o hash da senha digitada com o hash salvo. Se não bater, mostra *"E-mail ou senha inválidos."*
3. **Sessão:** o usuário logado fica guardado no `AuthService` enquanto o app está aberto.
4. **Proteção de telas:** toda navegação passa por `Rotas.gerarRota`. Se a tela é protegida (Home, Formulário) e ninguém está logado, o app abre o Login no lugar.
5. **Logout:** limpa a sessão e volta para o Login apagando o histórico de telas, então o botão "voltar" não retorna para a Home.

## Base de dados

Arquivo SQLite `minhas_tarefas.db`, criado automaticamente na primeira execução (`onCreate`), com duas tabelas:

**usuarios**

| Coluna | Tipo | Descrição |
|---|---|---|
| id | INTEGER PK AUTOINCREMENT | Identificador |
| nome | TEXT NOT NULL | Nome do usuário |
| email | TEXT NOT NULL UNIQUE | E-mail (não pode repetir) |
| senha_hash | TEXT NOT NULL | Hash SHA-256 da senha |

**tarefas**

| Coluna | Tipo | Descrição |
|---|---|---|
| id | INTEGER PK AUTOINCREMENT | Identificador |
| usuario_id | INTEGER NOT NULL (FK → usuarios.id) | Dono da tarefa |
| titulo | TEXT NOT NULL | Título |
| descricao | TEXT | Descrição (opcional) |
| concluida | INTEGER (0 ou 1) | SQLite não tem booleano |
| data_criacao | TEXT | Data/hora no formato ISO 8601 |
| data_entrega | TEXT (opcional) | Prazo no formato aaaa-mm-dd |

**Versões do banco:** a versão 1 criou as tabelas. A versão 2 adicionou a coluna `data_entrega`. Quem já tinha o app instalado recebe a coluna nova pelo `onUpgrade` (`ALTER TABLE`), sem perder as tarefas.

**Situação do prazo** (calculada em `Tarefa.statusPrazo()`):

| Situação | Regra | Cor |
|---|---|---|
| Vencida | data já passou | Vermelho |
| Vence hoje (urgente) | data = hoje | Laranja |
| Perto do prazo | faltam 1 ou 2 dias | Amarelo |
| Em dia | faltam 3 dias ou mais | Verde |
| Concluída / sem data | não gera alerta | Cinza / sem destaque |

A lista mostra primeiro as tarefas pendentes, ordenadas pela entrega mais próxima.

Todo o SQL fica em `services/database_service.dart`. As consultas usam `where: 'id = ?'` com `whereArgs`, o que evita SQL Injection.
