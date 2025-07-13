# Instagram AI Agent SaaS Platform

A comprehensive, multi-tenant SaaS web application that provides a GPT-4o powered agent to manage Instagram Direct Messages with admin-controlled whitelist access.

## Project Structure

```
/
├── backend/              # Azure Functions/App Service (Node.js/TypeScript)
├── frontend-merchant/    # React/Vite merchant dashboard
├── frontend-admin/       # React/Vite admin dashboard
├── .github/workflows/    # GitHub Actions CI/CD
└── docs/                # Project documentation
```

## Technology Stack

- **Cloud**: Microsoft Azure
- **AI Model**: GPT-4o (via Azure OpenAI Service)
- **Backend**: Azure Functions/App Service (Node.js/TypeScript)
- **Database**: Azure Cosmos DB (NoSQL API)
- **Frontend**: React with Vite on Azure Static Web Apps
- **CI/CD**: GitHub Actions
- **Secrets**: Azure Key Vault
- **Storage**: Azure Blob Storage
- **Search**: Azure Cognitive Search

## Core Features

- Admin-controlled merchant whitelist
- Instagram DM automation with GPT-4o
- Separate merchant and admin dashboards
- Product catalog management
- Order processing from chat
- Voice message transcription
- Sentiment analysis and intent detection
- Knowledge base integration (RAG)
- Proactive engagement features

## Development Phases

1. **Phase 0**: Project scaffolding & infrastructure
2. **Phase 1**: Vendor admin dashboard & whitelist control
3. **Phase 2**: Merchant onboarding & backend foundation
4. **Phase 3**: Basic AI conversation loop
5. **Phase 4**: Merchant dashboard V1
6. **Phase 5**: Advanced AI features
7. **Phase 6**: Order management system
8. **Phase 7**: Advanced platform features
9. **Phase 8**: Proactive engagement & growth

## Getting Started

### Prerequisites

- Node.js 18+
- Azure CLI
- Azure subscription
- Instagram Developer Account

### Installation

1. Clone the repository
2. Install dependencies for each component
3. Configure Azure resources
4. Set up environment variables
5. Deploy using GitHub Actions

## Repository

https://github.com/Samer-Is/INSTAAGENT

## License

Private - All rights reserved 