-- ===================================================================
-- Esquema Inicial para la Base de Datos de MECSOL AI System
-- Versión: 1.0
-- Descripción: Define las tablas principales para la gestión de
--              ventas, proyectos y clientes.
-- ===================================================================

-- Crear un ENUM para los estados de los leads y proyectos
CREATE TYPE lead_status AS ENUM ('new', 'contacted', 'qualified', 'proposal_sent', 'won', 'lost');
CREATE TYPE project_status AS ENUM ('pending', 'in_progress', 'completed', 'on_hold', 'cancelled');

-- Tabla de Clientes
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    contact_email VARCHAR(255) UNIQUE,
    contact_phone VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Leads
-- Almacena la información inicial de un cliente potencial.
CREATE TABLE IF NOT EXISTS leads (
    id SERIAL PRIMARY KEY,
    source VARCHAR(100), -- ej. 'website_form', 'social_media', 'manual'
    customer_id INTEGER REFERENCES customers(id),
    status lead_status DEFAULT 'new',
    lead_details JSONB, -- Para almacenar detalles flexibles como "tipo de maquinaria", "requerimientos"
    assigned_agent_id VARCHAR(100), -- ID del agente de IA asignado
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Cotizaciones
-- Almacena las propuestas económicas enviadas a los clientes.
CREATE TABLE IF NOT EXISTS quotes (
    id SERIAL PRIMARY KEY,
    lead_id INTEGER NOT NULL REFERENCES leads(id),
    quote_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'MXN',
    details JSONB, -- Para almacenar el desglose de la cotización
    sent_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Proyectos
-- Representa un trabajo de instalación de maquinaria vendido.
CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,
    quote_id INTEGER NOT NULL REFERENCES quotes(id),
    project_name VARCHAR(255) NOT NULL,
    status project_status DEFAULT 'pending',
    start_date DATE,
    end_date DATE,
    project_manager VARCHAR(100), -- Nombre del gestor humano
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Tareas del Proyecto
CREATE TABLE IF NOT EXISTS project_tasks (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id),
    task_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    due_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Crear una función para actualizar el campo 'updated_at' automáticamente
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar el trigger a las tablas relevantes
CREATE TRIGGER set_timestamp_customers BEFORE UPDATE ON customers FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_leads BEFORE UPDATE ON leads FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_projects BEFORE UPDATE ON projects FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();

COMMENT ON COLUMN leads.lead_details IS 'Almacena detalles del lead como: tipo de maquinaria, layout de planta, requerimientos eléctricos, etc.';
COMMENT ON COLUMN quotes.details IS 'Almacena el desglose de la cotización: coste de maquinaria, horas de instalación, viáticos, etc.';
