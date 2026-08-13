-- =====================================================
-- HIVU HR SYSTEM - SUPABASE SETUP
-- =====================================================

-- 1. CREATE TABLES

-- Company Settings Table
CREATE TABLE IF NOT EXISTS company_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  work_start_time TEXT DEFAULT '09:00',
  work_end_time TEXT DEFAULT '18:00',
  late_after_time TEXT DEFAULT '09:30',
  min_hours_per_day INT DEFAULT 8,
  penalty_per_late_hour INT DEFAULT -100,
  short_day_threshold INT DEFAULT 6,
  saturday_off BOOLEAN DEFAULT true,
  sunday_off BOOLEAN DEFAULT true,
  company_logo TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Employees Table
CREATE TABLE IF NOT EXISTS employees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  emp_id TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  designation TEXT,
  department TEXT,
  dob DATE,
  work_anniversary DATE,
  basic_salary INT DEFAULT 0,
  hra INT DEFAULT 0,
  pf_deduction INT DEFAULT 0,
  avatar TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Leave Types Table
CREATE TABLE IF NOT EXISTS leave_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  days_per_year INT NOT NULL,
  color TEXT DEFAULT '#0066FF',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Employee Leave Balance Table
CREATE TABLE IF NOT EXISTS employee_leave_balance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  emp_id TEXT NOT NULL,
  leave_type_id UUID NOT NULL REFERENCES leave_types(id),
  year INT NOT NULL,
  used INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(emp_id, leave_type_id, year)
);

-- Leave Requests Table
CREATE TABLE IF NOT EXISTS leave_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  emp_id TEXT NOT NULL,
  leave_type_id UUID NOT NULL REFERENCES leave_types(id),
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  days INT NOT NULL,
  reason TEXT,
  status TEXT DEFAULT 'Pending',
  approved_by TEXT,
  comments TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Attendance Logs Table
CREATE TABLE IF NOT EXISTS attendance_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  emp_id TEXT NOT NULL,
  date DATE NOT NULL,
  clock_in_time TEXT,
  clock_out_time TEXT,
  clock_in_lat DECIMAL(10, 8),
  clock_in_lng DECIMAL(11, 8),
  clock_out_lat DECIMAL(10, 8),
  clock_out_lng DECIMAL(11, 8),
  clock_in_accuracy INT,
  hours_worked TEXT,
  status TEXT DEFAULT 'Present',
  penalty INT DEFAULT 0,
  remarks TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(emp_id, date)
);

-- Company Holidays Table
CREATE TABLE IF NOT EXISTS company_holidays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  holiday_name TEXT NOT NULL,
  date DATE NOT NULL,
  description TEXT,
  is_restricted BOOLEAN DEFAULT false,
  year INT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Attendance Regularization Table
CREATE TABLE IF NOT EXISTS attendance_regularization (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  emp_id TEXT NOT NULL,
  date DATE NOT NULL,
  reason TEXT,
  status TEXT DEFAULT 'pending',
  rejection_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 2. INSERT TEST DATA
-- =====================================================

-- Insert Company Settings
INSERT INTO company_settings (
  work_start_time, work_end_time, late_after_time,
  min_hours_per_day, penalty_per_late_hour, short_day_threshold,
  saturday_off, sunday_off
) VALUES (
  '09:00', '18:00', '09:30',
  8, -100, 6,
  true, true
) ON CONFLICT DO NOTHING;

-- Insert Leave Types
INSERT INTO leave_types (name, days_per_year, color, is_active) VALUES
  ('Casual', 12, '#0066FF', true),
  ('Sick Leave', 6, '#FF4D6A', true),
  ('Paid Leave', 20, '#00C853', true),
  ('Unpaid Leave', 0, '#FFA500', true)
ON CONFLICT (name) DO NOTHING;

-- Insert Test Employees
INSERT INTO employees (emp_id, name, phone, email, designation, department, basic_salary, hra, pf_deduction, dob, work_anniversary) VALUES
  ('EMP001', 'Raj Kumar', '+919876543210', 'raj.kumar@company.com', 'Software Engineer', 'Engineering', 50000, 15000, 5000, '1995-05-15', '2022-01-15'),
  ('EMP002', 'Priya Sharma', '+919876543211', 'priya.sharma@company.com', 'Product Manager', 'Product', 60000, 18000, 6000, '1993-08-22', '2021-06-01'),
  ('EMP003', 'Amit Patel', '+919876543212', 'amit.patel@company.com', 'Data Analyst', 'Analytics', 45000, 13500, 4500, '1998-03-10', '2023-02-15'),
  ('EMP004', 'Neha Singh', '+919876543213', 'neha.singh@company.com', 'HR Manager', 'HR', 55000, 16500, 5500, '1992-11-28', '2020-09-01'),
  ('EMP005', 'Vikram Das', '+919876543214', 'vikram.das@company.com', 'DevOps Engineer', 'Engineering', 58000, 17400, 5800, '1996-07-05', '2021-11-15')
ON CONFLICT (emp_id) DO NOTHING;

-- Insert Employee Leave Balances for Current Year (2026)
INSERT INTO employee_leave_balance (emp_id, leave_type_id, year, used)
SELECT e.emp_id, lt.id, 2026, 0
FROM employees e
CROSS JOIN leave_types lt
WHERE lt.is_active = true
ON CONFLICT (emp_id, leave_type_id, year) DO NOTHING;

-- Insert Test Holidays
INSERT INTO company_holidays (holiday_name, date, description, is_restricted, year) VALUES
  ('New Year', '2026-01-26', 'Republic Day', false, 2026),
  ('Holi', '2026-03-25', 'Festival of Colors', false, 2026),
  ('Good Friday', '2026-04-10', 'Christian Holiday', false, 2026),
  ('Eid ul-Fitr', '2026-04-13', 'Islamic Festival', false, 2026),
  ('Independence Day', '2026-08-15', 'National Holiday', false, 2026),
  ('Diwali', '2026-10-29', 'Festival of Lights', false, 2026),
  ('Christmas', '2026-12-25', 'Christian Holiday', false, 2026)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 3. ENABLE ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_leave_balance ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_holidays ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_regularization ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_settings ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 4. CREATE RLS POLICIES (ANON KEY - READ ONLY FOR DEMO)
-- =====================================================

-- Employees - Allow read all
CREATE POLICY "Allow read all" ON employees
  FOR SELECT TO anon USING (true);

-- Leave Types - Allow read all
CREATE POLICY "Allow read all" ON leave_types
  FOR SELECT TO anon USING (true);

-- Leave Requests - Allow read all
CREATE POLICY "Allow read all" ON leave_requests
  FOR SELECT TO anon USING (true);

-- Allow insert leave requests
CREATE POLICY "Allow insert leave requests" ON leave_requests
  FOR INSERT TO anon WITH CHECK (true);

-- Allow update own leave requests
CREATE POLICY "Allow update own" ON leave_requests
  FOR UPDATE TO anon USING (true) WITH CHECK (true);

-- Employee Leave Balance - Allow read all
CREATE POLICY "Allow read all" ON employee_leave_balance
  FOR SELECT TO anon USING (true);

-- Attendance Logs - Allow read all
CREATE POLICY "Allow read all" ON attendance_logs
  FOR SELECT TO anon USING (true);

-- Allow insert attendance
CREATE POLICY "Allow insert attendance" ON attendance_logs
  FOR INSERT TO anon WITH CHECK (true);

-- Allow update attendance
CREATE POLICY "Allow update attendance" ON attendance_logs
  FOR UPDATE TO anon USING (true) WITH CHECK (true);

-- Company Holidays - Allow read all
CREATE POLICY "Allow read all" ON company_holidays
  FOR SELECT TO anon USING (true);

-- Company Settings - Allow read all
CREATE POLICY "Allow read all" ON company_settings
  FOR SELECT TO anon USING (true);

-- Allow update settings
CREATE POLICY "Allow update settings" ON company_settings
  FOR UPDATE TO anon USING (true) WITH CHECK (true);

-- Attendance Regularization - Allow read all
CREATE POLICY "Allow read all" ON attendance_regularization
  FOR SELECT TO anon USING (true);

-- Allow insert regularization
CREATE POLICY "Allow insert regularization" ON attendance_regularization
  FOR INSERT TO anon WITH CHECK (true);

-- Allow update regularization
CREATE POLICY "Allow update regularization" ON attendance_regularization
  FOR UPDATE TO anon USING (true) WITH CHECK (true);

-- =====================================================
-- 5. CREATE INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_employees_phone ON employees(phone);
CREATE INDEX IF NOT EXISTS idx_employees_emp_id ON employees(emp_id);
CREATE INDEX IF NOT EXISTS idx_attendance_logs_emp_id_date ON attendance_logs(emp_id, date);
CREATE INDEX IF NOT EXISTS idx_leave_requests_emp_id ON leave_requests(emp_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_status ON leave_requests(status);
CREATE INDEX IF NOT EXISTS idx_attendance_regularization_emp_id ON attendance_regularization(emp_id);
