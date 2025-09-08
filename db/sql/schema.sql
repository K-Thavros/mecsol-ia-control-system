-- ===================================================================
-- Archivo: schema.sql
-- Descripción: DDL para la base de datos central de MECSOL.
-- Define las tablas para entidades de negocio clave y vistas para KPIs.
-- ===================================================================

-- Habilitar extensiones útiles si no existen
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===================================================================
-- Definición de Tipos (Enums) para consistencia de datos
-- ===================================================================
CREATE TYPE lead_status AS ENUM ('new', 'contacted', 'qualified', 'proposal_sent', 'won', 'lost');
CREATE TYPE project_status AS ENUM ('planning', 'in_progress', 'completed', 'on_hold', 'cancelled');
CREATE TYPE ticket_status AS ENUM ('open', 'in_progress', 'resolved', 'closed');
CREATE TYPE campaign_type AS ENUM ('email', 'whatsapp', 'social_media', 'sms');

-- ===================================================================
-- Tabla de Clientes (almacena información de clientes consolidados)
-- ===================================================================
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    rfc VARCHAR(13) UNIQUE, -- Registro Federal de Contribuyentes (México)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_clients_email ON clients(email);

-- ===================================================================
-- Tabla de Leads (registra todos los prospectos de venta)
-- ===================================================================
CREATE TABLE leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source VARCHAR(100), -- ej. 'www.mecsol.mx', 'LinkedIn'
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    status lead_status DEFAULT 'new',
    estimated_value NUMERIC(12, 2) DEFAULT 0.00,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_leads_status ON leads(status);

-- ===================================================================
-- Tabla de Proyectos (gestiona proyectos de ventas concretadas)
-- ===================================================================
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    status project_status DEFAULT 'planning',
    start_date DATE,
    end_date DATE,
    budget NUMERIC(12, 2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_client_id ON projects(client_id);

-- ===================================================================
-- Tabla de Facturas (registro simplificado, puede ser sincronizado desde Odoo)
-- ===================================================================
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    paid_date DATE,
    status VARCHAR(20) DEFAULT 'issued', -- ej. 'issued', 'paid', 'overdue'
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_invoices_status ON invoices(status);

-- ===================================================================
-- Tabla de Tickets de Soporte
-- ===================================================================
CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    contact_email VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT,
    status ticket_status DEFAULT 'open',
    priority INT DEFAULT 3, -- 1=Alto, 2=Medio, 3=Bajo
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);
CREATE INDEX idx_support_tickets_status ON support_tickets(status);

-- ===================================================================
-- Tabla de Campañas de Marketing
-- ===================================================================
CREATE TABLE marketing_campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    type campaign_type NOT NULL,
    start_date DATE,
    end_date DATE,
    budget NUMERIC(10, 2),
    leads_generated INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===================================================================
-- Vistas para KPIs (Key Performance Indicators) para Grafana
-- ===================================================================

CREATE OR REPLACE VIEW view_kpi_sales AS
SELECT
    COUNT(*) AS total_leads,
    COUNT(CASE WHEN status = 'won' THEN 1 END) AS won_leads,
    COUNT(CASE WHEN status = 'lost' THEN 1 END) AS lost_leads,
    COALESCE(SUM(CASE WHEN status = 'won' THEN estimated_value ELSE 0 END), 0) AS total_revenue_won,
    (COUNT(CASE WHEN status = 'won' THEN 1 END)::float / NULLIF(COUNT(*), 0)::float) * 100 AS conversion_rate_percentage,
    date_trunc('day', created_at) as day
FROM leads
GROUP BY day;

CREATE OR REPLACE VIEW view_kpi_projects AS
SELECT
    status,
    COUNT(*) as project_count,
    COALESCE(SUM(budget), 0) as total_budget
FROM projects
GROUP BY status;

CREATE OR REPLACE VIEW view_kpi_support AS
SELECT
    status,
    COUNT(*) as ticket_count,
    AVG(EXTRACT(EPOCH FROM (resolved_at - created_at)))) as avg_resolution_time_seconds
FROM support_tickets
GROUP BY status;
