# Pipeline de Infraestrutura AWS com Terraform e GitHub Actions

[![en](https://img.shields.io/badge/lang-en-blue.svg)](https://github.com/andresinho20049/terraform-pipeline-with-github-actions/blob/main/README.md)

Este projeto oferece uma solução robusta para o gerenciamento e provisionamento de infraestrutura na Amazon Web Services (AWS) utilizando Terraform, com um pipeline de Continuous Integration/Continuous Deployment (CI/CD) automatizado através do GitHub Actions.

## 🚀 Visão Geral
O objetivo principal deste repositório é permitir que você defina, provisione e atualize sua infraestrutura AWS de forma declarativa e automatizada. Ao realizar um git push para este repositório, o GitHub Actions se encarregará de executar os comandos do Terraform, garantindo que sua infraestrutura na AWS esteja sempre sincronizada com suas configurações definidas no código.

## ✨ Funcionalidades Principais
Infraestrutura como Código (IaC) com Terraform: Defina sua infraestrutura AWS usando arquivos de configuração Terraform, garantindo reprodutibilidade e versionamento.

* **Automação de CI/CD com GitHub Actions**: Um pipeline pré-configurado que automatiza o processo de terraform plan e terraform apply a cada push para o repositório.

* **Gerenciamento de State Remoto no S3**: O statefile do Terraform é armazenado de forma segura em um bucket S3, facilitando o trabalho em equipe e a recuperação de desastres.

* **State Locking com DynamoDB**: Uma tabela DynamoDB é utilizada para garantir o bloqueio do statefile durante as operações do Terraform, prevenindo conflitos e corrupção de estado em ambientes colaborativos.

* **Integração Segura com AWS**: A autenticação entre o GitHub Actions e sua conta AWS é estabelecida através de um provedor de identidade (OIDC) e uma Role IAM pré-configurados em sua conta AWS, permitindo que o pipeline assuma as permissões necessárias para gerenciar sua infraestrutura.

## 🚀 Como Funciona

Este projeto otimiza o deploy da sua infraestrutura e site estático na AWS através de um pipeline automatizado de **CI/CD**. Veja como ele funciona:

1.  **Desenvolvimento da Infraestrutura:** Você define ou atualiza sua infraestrutura AWS usando **Terraform** nos arquivos `.tf` localizados no diretório `infra/` do repositório.
2.  **Commit e Push:** Ao realizar um `git commit` e `git push` para o branch principal (ou qualquer branch configurado para acionar o workflow), o pipeline do GitHub Actions é automaticamente acionado.
3.  **Execução do Pipeline GitHub Actions:**
    * O workflow inicia, efetuando o **checkout** do seu código.
    * Ele assume uma **Role IAM** específica na sua conta AWS, garantindo acesso seguro via **OIDC**.
    * Executa `terraform init`, que configura o **backend S3** para armazenamento do **statefile** e a **tabela DynamoDB** para **state locking**, prevenindo conflitos.
    * Realiza `terraform plan` para gerar e exibir um resumo das mudanças propostas para sua infraestrutura.
    * Executa `terraform apply --auto-approve` para aplicar essas mudanças, provisionando ou atualizando os recursos na AWS.
    * **Upload de Conteúdo:** Após a infraestrutura ser provisionada, os arquivos do seu site estático (localizados em `src/`) são sincronizados para o **bucket S3** usando `aws s3 sync --delete`, garantindo que seu site esteja sempre atualizado e acessível.
4.  **Infraestrutura e Site Atualizados:** Sua infraestrutura na AWS é provisionada ou atualizada conforme as configurações do Terraform, e seu site estático fica imediatamente disponível.

## 〰️ Recursos Provisionados

O Terraform é responsável por provisionar e configurar os seguintes recursos essenciais na sua conta AWS:

* **Bucket S3 para Site Estático:** Um bucket Amazon S3 configurado especificamente para hospedar seu site estático.
* **Versionamento de Objetos:** O versionamento é habilitado no bucket S3, permitindo o rollback de arquivos do site para versões anteriores.
* **Política de Acesso Público:** Uma política de bucket S3 é anexada para permitir que os objetos do site sejam publicamente acessíveis via internet.
* **Configuração de Website Hosting:** O bucket é configurado para funcionar como um website estático, definindo `index.html` como o documento de índice padrão e `error.html` como o documento de erro.
* **Gerenciamento de Ciclo de Vida (Lifecycle):** Regras de ciclo de vida são aplicadas ao bucket S3 para gerenciar automaticamente as versões não atuais dos objetos. Especificamente, as **versões não atuais (noncurrent versions) de objetos a partir da 4ª serão permanentemente deletadas**, otimizando custos e o gerenciamento de versões.

Os arquivos HTML, CSS e outros assets do seu site estático, como `index.html` e `error.html`, estão presentes no diretório `src/` do repositório e são automaticamente carregados para o bucket S3 durante o processo do pipeline.

## 🎯 Como Executar

Este projeto utiliza **Terraform** para provisionar a infraestrutura e **GitHub Actions** para automação de CI/CD, garantindo um deploy de site estático na AWS. Siga os passos abaixo para configurá-lo e executá-lo em seu ambiente:

### 1\. Pré-requisitos na AWS

Antes de iniciar, certifique-se de que sua conta AWS esteja configurada com os seguintes recursos:

  * **Provider OIDC para GitHub Actions:** Configure um provedor de identidade (OIDC) no AWS IAM para permitir que o GitHub Actions assuma uma **Role IAM** de forma segura. Para um guia detalhado, consulte a documentação oficial da AWS: [Use IAM roles to connect GitHub Actions to actions in AWS](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/).
  * **Role IAM Dedicada:** Crie uma Role IAM específica para o GitHub Actions. Ela precisará das **políticas de permissão necessárias** para gerenciar todos os recursos da sua infraestrutura, incluindo:
      * **S3:** Criar e configurar buckets, gerenciar objetos.
      * **DynamoDB:** Criar e acessar tabelas de lock para o Terraform.
      * **CloudFront:** Criar, configurar e gerenciar distribuições, OACs (Origin Access Controls) e políticas de cache.
      * Outros serviços AWS que sua solução Terraform possa provisionar.

      **Importante:** Verifique sempre a saída do Terraform para erros de `AccessDenied` e adicione as permissões faltantes à sua Role IAM.
  * **Bucket S3 para Statefile:** Tenha um bucket S3 previamente criado e dedicado ao armazenamento do seu **Terraform Statefile**. Este bucket é crucial para o gerenciamento de estado da sua infraestrutura e deve ter o **versionamento habilitado** para possibilitar rollbacks.
  * **Tabela DynamoDB para State Locking:** Crie uma tabela no DynamoDB para ser utilizada como um mecanismo de **lock de estado** pelo Terraform. Isso evita que múltiplas execuções do Terraform corrompam o `statefile` em ambientes colaborativos. A tabela deve ter uma **Partition Key** chamada `LockID` do tipo `String`.

-----

### 2\. Configuração do Repositório GitHub

Após configurar sua conta AWS, você precisará configurar as secrets no seu repositório GitHub para que o pipeline do GitHub Actions possa interagir com a AWS.

Navegue até **Settings** \> **Secrets and variables** \> **Actions** no seu repositório GitHub e adicione as seguintes secrets:

  * `AWS_ROLE_ARN`: O ARN da Role IAM que o GitHub Actions irá assumir (ex: `arn:aws:iam::123456789012:role/github-actions-role`).
  * `AWS_STATEFILE_S3_BUCKET`: O nome do bucket S3 onde seu Terraform Statefile será armazenado.
  * `AWS_LOCK_DYNAMODB_TABLE`: O nome da tabela DynamoDB configurada para o lock de estado do Terraform.

-----

### 3\. Execução do Pipeline

Com os pré-requisitos da AWS e as secrets do GitHub configuradas, você está pronto para executar o pipeline:

1.  **Clone o Projeto:**

    ```bash
    git clone https://github.com/andresinho20049/terraform-pipeline-with-github-actions.git
    cd terraform-pipeline-with-github-actions
    ```

2.  **Realize uma Alteração e Faça Commit/Push:**
    Faça qualquer alteração no código do projeto (por exemplo, em um dos arquivos HTML em `src/` ou nas configurações do Terraform em `infra/`).

    ```bash
    git add .
    git commit -m "Minhas mensagem de commit"
    git push origin main 
    ```

3.  **Acompanhe o Pipeline:**

    Após o `git push`, o pipeline do GitHub Actions será executado automaticamente. Você pode acompanhar o progresso na aba **Actions** do seu repositório GitHub. O pipeline irá provisionar ou atualizar a infraestrutura na AWS e, em seguida, fazer o upload dos arquivos do seu site estático para o bucket S3 configurado.

Com esses passos, sua infraestrutura será provisionada e seu site estático estará online na AWS, tudo de forma automatizada via GitHub Actions!

## ©️ Copyright
**Developed by** [Andresinho20049](https://andresinho20049.com.br/) \
**Project**: *Infraestrutura Automática na AWS com IaC (Terraform)* \
**Description**: \
Este projeto oferece uma solução robusta para Infraestrutura como Código (IaC) e CI/CD contínuo para sites estáticos na AWS. Utilizando Terraform, provisionamos e gerenciamos a infraestrutura de forma declarativa, incluindo um bucket S3 para hospedagem do site e uma tabela DynamoDB para state locking, garantindo a integridade do Terraform Statefile em ambientes colaborativos.

A automação é orquestrada via GitHub Actions, que executa um pipeline de CI/CD, realizando terraform plan e apply automaticamente a cada push. A integração segura com a AWS é feita através de IAM Roles e OIDC (OpenID Connect), eliminando a necessidade de credenciais de longa duração. Além disso, o pipeline utiliza aws s3 sync para upload eficiente do conteúdo estático, mantendo o bucket S3 sempre sincronizado com o repositório.

Essa abordagem otimiza o workflow de desenvolvimento, assegura a reprodutibilidade da infraestrutura e facilita a colaboração entre equipes, resultando em deployments rápidos, consistentes e seguros.