# 🩺 HelpACS — Sistema de Apoio ao Agente Comunitário de Saúde

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-1A237E?style=for-the-badge&logo=dart&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-NoSQL-yellow?style=for-the-badge)

Aplicativo móvel multiplataforma **offline-first** desenvolvido em Flutter, Riverpod e Hive para ajudar Agentes Comunitários de Saúde (ACS) a organizar e acompanhar informações durante o trabalho de campo.

O aplicativo busca reunir as informações dos pacientes em um único lugar, facilitando a consulta durante as visitas domiciliares e calculando automaticamente quais acompanhamentos estão em dia, precisam de atenção ou estão atrasados.

---

## 🎯 Contexto e Motivação

A ideia do HelpACS surgiu a partir de uma situação muito comum na rotina do ACS: ter que acompanhar várias informações ao mesmo tempo, como vacinação, pré-natal, saúde da mulher e acompanhamento infantil. 

Antes do aplicativo, esse tipo de controle poderia ficar espalhado entre planilhas do Excel, cadernos, fichas de gestantes e cópias de cartões de vacinação. Além da dificuldade para organizar tudo e do volume de documentos físicos carregados no dia a dia, identificar rapidamente os vencimentos e pendências era um processo demorado e manual.

## 💡 O que o HelpACS busca resolver

O aplicativo foi projetado para focar em três pilares principais:

1. **Organizar as informações:** Reunir os dados dos pacientes e seus acompanhamentos de forma centralizada.
2. **Identificar pendências visualmente:** Mostrar de forma rápida situações baseadas em cores: 🟢 Em dia, 🟡 Atenção, 🔴 Atrasado, ⚪ Pendente.
3. **Evitar cálculos manuais:** O app utiliza idades e datas (como a Data da Última Menstruação) para calcular automaticamente próximos vencimentos, status de acompanhamento e a Idade Gestacional.

---

## 🚀 Principais Funcionalidades

| Módulo | Destaques |
|---|---|
| **Vacinação Infantil** | Calendário editável no banco, registro de doses, vacinas de campanha, registro de vacinas personalizadas e alerta de atrasos. |
| **Saúde da Mulher** | Controle de Preventivo (anual) e Mamografia (bienal), dashboard visual com contadores de status e separação SUS/Particular. |
| **Pré-Natal** | Cálculo automático de Idade Gestacional (DUM/DPP), controle do roteiro de consultas, exames, ultrassons e anexo de documentos. |
| **Nutrição Infantil** | Avaliação do consumo alimentar via formulários segmentados por faixas etárias (< 6m, 6–23m, 2–10a) e histórico de acompanhamento. |
| **Utilitários e Agenda** | Importação em lote de pacientes via CSV/Excel, agenda e mural de avisos (com calendário interativo) e gerenciador de tarefas. |

---

## 📴 Funcionamento Offline e Tecnologias

Uma das decisões arquiteturais mais importantes do projeto foi **fazer o aplicativo funcionar 100% sem depender da internet**. Como a rotina de visitas domiciliares ocorre em locais onde a conexão falha frequentemente, uma abordagem offline-first era essencial.

* **Flutter / Dart:** Framework utilizado para a interface e lógica de negócio.
* **Hive (NoSQL):** Banco de dados local utilizado para armazenar os dados diretamente no dispositivo, sem depender de uma API ou servidor remoto.
* **Riverpod:** Gerenciamento de estado reativo. Quando os dados mudam no banco, a interface se atualiza automaticamente.
* **Bibliotecas Auxiliares:** `csv` e `excel` (processamento de planilhas locais) e `syncfusion_flutter_calendar` (mural interativo).

---

## 🧩 Arquitetura e Organização de Código

O projeto é organizado por funcionalidades (**Feature-first**), separando claramente a Interface, o Gerenciamento de Estado, as Regras de Negócio e a Persistência. Essa separação ajuda a manter as regras de negócio independentes da interface.

```mermaid
flowchart TD
    UI["Apresentação (UI)<br/>Telas e Formulários"]
    STATE["Estado<br/>(Riverpod / Controllers)"]
    SERVICE["Regras de Negócio<br/>(Services)"]
    MODEL["Modelos<br/>(HiveObjects)"]
    DB[("Banco de Dados<br/>(Hive Local)")]

    UI -->|"Informa ações"| STATE
    STATE -->|"Valida regras"| SERVICE
    SERVICE -->|"Atualiza"| MODEL
    STATE -->|"Operações CRUD"| MODEL
    MODEL -->|"Persistência binária"| DB
    DB -->|"Notifica UI via State"| STATE

```

---

## 📚 O que estou aprendendo com este projeto

O HelpACS começou como uma tentativa de resolver um problema prático e acabou se tornando uma forma de colocar conceitos de engenharia de software em prática.

Uma das partes mais interessantes foi perceber que **algumas decisões iniciais precisaram ser revistas conforme o app cresceu**. Por exemplo: o catálogo de vacinas começou *hardcoded* (fixo no código), mas percebi que isso exigiria atualizar o app inteiro a cada mudança do Ministério da Saúde. Refatorei o projeto para transformar o catálogo em uma estrutura editável persistida no banco, usando estratégias de referências de *snapshot* para não quebrar registros antigos de pacientes. Esse processo de identificar problemas, testar soluções e refatorar conforme o projeto crescia acabou sendo uma das partes que mais contribuíram para o meu aprendizado.

## 🔐 Segurança e Próximos Passos

Como desenvolvedor, entendo que o projeto está em evolução. Atualmente, o app valida inputs, normaliza dados de planilhas e exige confirmação para ações destrutivas. Contudo, mapeei os seguintes pontos de melhoria técnica para o futuro:

* Implementação de autenticação por usuário e controle de acesso local.
* Criação de uma rotina de backup ou sincronização em nuvem para evitar perda de dados caso o celular quebre.
* Ampliação da cobertura de testes automatizados unitários para os `Services`.

---

## 🎓 Futuro TCC e Próximos Desafios

O HelpACS está servindo como base prática para meu **Trabalho de Conclusão de Curso (Sistemas de Informação)**. O objetivo não é apenas finalizar este app, mas usá-lo como alicerce técnico. Futuramente, pretendo reconstruir parte dessa aplicação utilizando **Kotlin e Android Nativo**, aprofundando meus conhecimentos em tecnologias como:

* Jetpack Compose e UI Declarativa.
* Room Database.
* Princípios de MVVM e Clean Architecture.
* Coroutines e Flow.

---

## 📸 Demonstração

Tela inicial

<p align="center"> <img src="docs/screenshots/Home_Page.png" alt="Tela inicial" width="220"> </p>

Vacinação

<p align="center"> <img src="docs/screenshots/Vacinação.png" alt="Módulo de vacinação" width="220"> <img src="docs/screenshots/Cadastro_paciente.png" alt="Cadastro de paciente" width="220"> <img src="docs/screenshots/Campanhas.png" alt="Campanhas" width="220"> </p>

<p align="center"> <img src="docs/screenshots/Cronograma_vacinal.png" alt="Cronograma vacinal" width="220"> <img src="docs/screenshots/Cronograma_aplicadas.png" alt="Vacinas aplicadas" width="220"> <img src="docs/screenshots/Upload_midia.png" alt="Upload de mídia" width="220"> </p>

Saúde da Mulher

<p align="center"> <img src="docs/screenshots/Saúde_mulher.png" alt="Saúde da Mulher" width="220"> <img src="docs/screenshots/Acompanhamento.png" alt="Acompanhamento" width="220"> <img src="docs/screenshots/Cadastro_mulher.png" alt="Cadastro da mulher" width="220"> </p>

Pré-Natal

<p align="center"> <img src="docs/screenshots/Pré_Natal.png" alt="Pré-Natal" width="220"> <img src="docs/screenshots/Cadastro_gestantes.png" alt="Cadastro de gestantes" width="220"> <img src="docs/screenshots/Editar_gestantes.png" alt="Editar gestante" width="220"> </p>

<p align="center"> <img src="docs/screenshots/Consultas_gestantes.png" alt="Consultas" width="220"> <img src="docs/screenshots/Ultrassons_gestantes.png" alt="Ultrassons" width="220"> <img src="docs/screenshots/Exames_gestantes.png" alt="Exames" width="220"> </p>

<p align="center"> <img src="docs/screenshots/Vacinas_gestantes.png" alt="Vacinas" width="220"> <img src="docs/screenshots/Galeria_gestantes.png" alt="Galeria" width="220"> </p>

Notes

<p align="center"> <img src="docs/screenshots/Notes.png" alt="Módulo Notas" width="220"> </p>

Calendar

<p align="center"> <img src="docs/screenshots/Calendar.png" alt="Módulo Calendário" width="220"> </p>

Consumo Alimentar

<p align="center"> <img src="docs/screenshots/Consumo_Alimentar.png" alt="Consumo Alimentar" width="220"> <img src="docs/screenshots/Historico_Alimentar.png" alt="Histórico Alimentar" width="220"> <img src="docs/screenshots/Relatorio_Geral_Nutri.png" alt="Relatório Geral de Nutrição" width="220"> </p>

Profile

<p align="center"> <img src="docs/screenshots/Profile.png" alt="Perfil" width="220"> </p>

## ▶️ Como Executar o Projeto

**Pré-requisitos:** Flutter SDK, Dart e um Emulador Android/iOS ou dispositivo físico configurado.

1. Clone o repositório:

```bash
git clone <URL_DO_REPOSITORIO>
cd <NOME_DO_PROJETO>

```

2. Instale as dependências:

```bash
flutter pub get

```

3. **Geração de código do Hive (Obrigatório):**

```bash
dart run build_runner build --delete-conflicting-outputs

```

4. Execute a aplicação:

```bash
flutter run

```

---

**👨‍💻 Desenvolvido por:** Rodrigo Valentino

*Projeto concebido com foco em aprendizado e portfólio técnico em Sistemas de Informação.*

> 📌 **Observação:** O HelpACS é um projeto acadêmico e em desenvolvimento contínuo. Não deve ser considerado, em sua versão atual, um substituto dos sistemas institucionais do SUS. O uso de dados reais de pacientes em campo requer adequação completa às normas de segurança e à LGPD.
