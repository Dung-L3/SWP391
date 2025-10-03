/* ================== CLEAN BUILD ================== */
IF DB_ID(N'RMS') IS NOT NULL
BEGIN
  ALTER DATABASE RMS SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE RMS;
END;
GO
CREATE DATABASE RMS;
GO
USE RMS;
GO

/* ========== Users, Roles, Permissions ========== */
CREATE TABLE dbo.users (
  user_id           INT IDENTITY(1,1) PRIMARY KEY,
  username          NVARCHAR(100) NOT NULL UNIQUE,
  email             NVARCHAR(191) NOT NULL UNIQUE,
  password_hash     NVARCHAR(255) NOT NULL,
  first_name        NVARCHAR(100),
  last_name         NVARCHAR(100),
  phone             NVARCHAR(30),
  address           NVARCHAR(255),
  registration_date DATETIME2(0) DEFAULT SYSDATETIME(),
  last_login        DATETIME2(0),
  account_status    NVARCHAR(20) NOT NULL DEFAULT N'ACTIVE'
    CONSTRAINT CK_users_account_status CHECK (account_status IN (N'ACTIVE',N'LOCKED',N'DISABLED',N'PENDING')),
  failed_login_attempts INT NOT NULL DEFAULT 0,
  lockout_until     DATETIME2(0),
  created_at        DATETIME2(0) DEFAULT SYSDATETIME(),
  updated_at        DATETIME2(0) DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.roles (
  role_id     INT IDENTITY(1,1) PRIMARY KEY,
  role_name   NVARCHAR(100) NOT NULL UNIQUE,  -- Manager, Receptionist, Waiter, Chef, Customer
  description NVARCHAR(255),
  status      NVARCHAR(20) NOT NULL DEFAULT N'ACTIVE'
    CONSTRAINT CK_roles_status CHECK (status IN (N'ACTIVE',N'INACTIVE')),
  created_at  DATETIME2(0) DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.permissions (
  permission_id   INT IDENTITY(1,1) PRIMARY KEY,
  permission_name NVARCHAR(150) NOT NULL,
  description     NVARCHAR(255),
  module          NVARCHAR(100),
  action          NVARCHAR(50),
  CONSTRAINT UQ_permissions UNIQUE (module, action)
);
GO

CREATE TABLE dbo.user_roles (
  user_role_id INT IDENTITY(1,1) PRIMARY KEY,
  user_id      INT NOT NULL,
  role_id      INT NOT NULL,
  assigned_date DATETIME2(0) DEFAULT SYSDATETIME(),
  status NVARCHAR(20) NOT NULL DEFAULT N'ACTIVE'
    CONSTRAINT CK_user_roles_status CHECK (status IN (N'ACTIVE',N'INACTIVE')),
  CONSTRAINT UQ_user_roles UNIQUE (user_id, role_id),
  CONSTRAINT FK_user_roles_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id),
  CONSTRAINT FK_user_roles_role FOREIGN KEY (role_id) REFERENCES dbo.roles(role_id)
);
GO

CREATE TABLE dbo.role_permissions (
  role_permission_id INT IDENTITY(1,1) PRIMARY KEY,
  role_id      INT NOT NULL,
  permission_id INT NOT NULL,
  assigned_date DATETIME2(0) DEFAULT SYSDATETIME(),
  CONSTRAINT UQ_role_permissions UNIQUE (role_id, permission_id),
  CONSTRAINT FK_role_permissions_role FOREIGN KEY (role_id) REFERENCES dbo.roles(role_id),
  CONSTRAINT FK_role_permissions_perm FOREIGN KEY (permission_id) REFERENCES dbo.permissions(permission_id)
);
GO

CREATE TABLE dbo.sessions (
  session_id    BIGINT IDENTITY(1,1) PRIMARY KEY,
  user_id       INT NOT NULL,
  access_token  NVARCHAR(255) NOT NULL,
  refresh_token NVARCHAR(255),
  created_at    DATETIME2(0) DEFAULT SYSDATETIME(),
  expires_at    DATETIME2(0),
  ip_address    NVARCHAR(64),
  user_agent    NVARCHAR(255),
  status        NVARCHAR(20) NOT NULL DEFAULT N'ACTIVE'
    CONSTRAINT CK_sessions_status CHECK (status IN (N'ACTIVE',N'REVOKED',N'EXPIRED')),
  CONSTRAINT FK_sessions_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id)
);
GO

CREATE TABLE dbo.password_resets (
  reset_id    BIGINT IDENTITY(1,1) PRIMARY KEY,
  user_id     INT NOT NULL,
  reset_token NVARCHAR(255) NOT NULL UNIQUE,
  created_at  DATETIME2(0) DEFAULT SYSDATETIME(),
  expires_at  DATETIME2(0),
  used        BIT NOT NULL DEFAULT 0,
  ip_address  NVARCHAR(64),
  CONSTRAINT FK_password_resets_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id)
);
GO

/* ========== People ========== */
CREATE TABLE dbo.customers (
  customer_id       INT IDENTITY(1,1) PRIMARY KEY,
  user_id           INT UNIQUE NULL,
  full_name         NVARCHAR(150),
  email             NVARCHAR(191),
  phone             NVARCHAR(30),
  address           NVARCHAR(255),
  registration_date DATETIME2(0) DEFAULT SYSDATETIME(),
  loyalty_points    INT NOT NULL DEFAULT 0,
  customer_type     NVARCHAR(20) NOT NULL DEFAULT N'WALK_IN'
    CONSTRAINT CK_customers_type CHECK (customer_type IN (N'WALK_IN',N'MEMBER',N'VIP')),
  CONSTRAINT FK_customers_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.staff (
  staff_id   INT IDENTITY(1,1) PRIMARY KEY,
  user_id    INT UNIQUE NULL,
  first_name NVARCHAR(100),
  last_name  NVARCHAR(100),
  email      NVARCHAR(191),
  phone      NVARCHAR(30),
  position   NVARCHAR(100),
  hire_date  DATE,
  salary     DECIMAL(12,2),
  status     NVARCHAR(20) NOT NULL DEFAULT N'ACTIVE'
    CONSTRAINT CK_staff_status CHECK (status IN (N'ACTIVE',N'INACTIVE')),
  manager_id INT NULL,
  CONSTRAINT FK_staff_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id) ON DELETE SET NULL
);
GO
ALTER TABLE dbo.staff
  ADD CONSTRAINT FK_staff_manager FOREIGN KEY (manager_id)
      REFERENCES dbo.staff(staff_id);
GO

/* ========== Areas / Tables ========== */
CREATE TABLE dbo.table_area (
  area_id    INT IDENTITY(1,1) PRIMARY KEY,
  area_name  NVARCHAR(100) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0
);
GO

CREATE TABLE dbo.dining_table (
  table_id     INT IDENTITY(1,1) PRIMARY KEY,
  area_id      INT NULL,
  table_number NVARCHAR(20) NOT NULL,
  capacity     INT NOT NULL,
  location     NVARCHAR(100),
  status       NVARCHAR(20) NOT NULL DEFAULT N'VACANT'
    CONSTRAINT CK_table_status CHECK (status IN (N'VACANT',N'HELD',N'SEATED',N'IN_USE',N'REQUEST_BILL',N'CLEANING',N'OUT_OF_SERVICE')),
  table_type   NVARCHAR(20) NOT NULL DEFAULT N'REGULAR'
    CONSTRAINT CK_table_type CHECK (table_type IN (N'REGULAR',N'VIP',N'OUTDOOR',N'BAR')),
  map_x        INT,
  map_y        INT,
  created_by   INT NULL,
  CONSTRAINT UQ_dining_table_number UNIQUE (table_number),
  CONSTRAINT FK_table_area FOREIGN KEY (area_id) REFERENCES dbo.table_area(area_id) ON DELETE SET NULL,
  CONSTRAINT FK_table_creator FOREIGN KEY (created_by) REFERENCES dbo.users(user_id) ON DELETE SET NULL
);
GO

/* ========== Suppliers / Inventory ========== */
CREATE TABLE dbo.suppliers (
  supplier_id    INT IDENTITY(1,1) PRIMARY KEY,
  company_name   NVARCHAR(150) NOT NULL,
  contact_person NVARCHAR(100),
  email          NVARCHAR(191),
  phone          NVARCHAR(30),
  address        NVARCHAR(255),
  status         NVARCHAR(20) NOT NULL DEFAULT N'ACTIVE'
    CONSTRAINT CK_suppliers_status CHECK (status IN (N'ACTIVE',N'INACTIVE')),
  created_by     INT NULL,
  CONSTRAINT FK_suppliers_creator FOREIGN KEY (created_by) REFERENCES dbo.users(user_id) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.inventory_items (
  item_id        INT IDENTITY(1,1) PRIMARY KEY,
  item_name      NVARCHAR(150) NOT NULL,
  category       NVARCHAR(100),
  uom            NVARCHAR(30) NOT NULL DEFAULT N'unit',
  current_stock  DECIMAL(12,3) NOT NULL DEFAULT 0,
  minimum_stock  DECIMAL(12,3) NOT NULL DEFAULT 0,
  unit_cost      DECIMAL(12,2) NOT NULL DEFAULT 0,
  supplier_id    INT NULL,
  expiry_date    DATE,
  status         NVARCHAR(20) NOT NULL DEFAULT N'ACTIVE'
    CONSTRAINT CK_inventory_status CHECK (status IN (N'ACTIVE',N'INACTIVE')),
  created_by     INT NULL,
  CONSTRAINT FK_inventory_supplier FOREIGN KEY (supplier_id) REFERENCES dbo.suppliers(supplier_id) ON DELETE SET NULL,
  CONSTRAINT FK_inventory_creator FOREIGN KEY (created_by) REFERENCES dbo.users(user_id) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.stock_transactions (
  stock_txn_id BIGINT IDENTITY(1,1) PRIMARY KEY,
  item_id   INT NOT NULL,
  txn_type  NVARCHAR(20) NOT NULL
    CONSTRAINT CK_stock_txn_type CHECK (txn_type IN (N'IN',N'OUT',N'USAGE',N'WASTE',N'ADJUSTMENT',N'RETURN')),
  quantity  DECIMAL(12,3) NOT NULL,
  unit_cost DECIMAL(12,2) NOT NULL DEFAULT 0,
  txn_time  DATETIME2(0) DEFAULT SYSDATETIME(),
  ref_type  NVARCHAR(50),
  ref_id    BIGINT,
  note      NVARCHAR(255),
  CONSTRAINT FK_stock_item FOREIGN KEY (item_id) REFERENCES dbo.inventory_items(item_id)
);
GO

/* ========== Menu / Modifiers / Pricing / Recipes ========== */
CREATE TABLE dbo.menu_categories (
  category_id   INT IDENTITY(1,1) PRIMARY KEY,
  category_name NVARCHAR(100) NOT NULL,
  sort_order    INT NOT NULL DEFAULT 0
);
GO

CREATE TABLE dbo.menu_items (
  menu_item_id     INT IDENTITY(1,1) PRIMARY KEY,
  category_id      INT NULL,
  name             NVARCHAR(150) NOT NULL,
  description      NVARCHAR(MAX),
  base_price       DECIMAL(12,2) NOT NULL,
  availability     NVARCHAR(20) NOT NULL DEFAULT N'AVAILABLE'
    CONSTRAINT CK_menu_availability CHECK (availability IN (N'AVAILABLE',N'TEMP_UNAVAILABLE',N'86')),
  preparation_time INT,
  image_url        NVARCHAR(255),
  is_active        BIT NOT NULL DEFAULT 1,
  created_by       INT NULL,
  CONSTRAINT FK_menu_category FOREIGN KEY (category_id) REFERENCES dbo.menu_categories(category_id) ON DELETE SET NULL,
  CONSTRAINT FK_menu_creator FOREIGN KEY (created_by) REFERENCES dbo.users(user_id) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.modifier_groups (
  group_id    INT IDENTITY(1,1) PRIMARY KEY,
  group_name  NVARCHAR(100) NOT NULL,
  is_required BIT NOT NULL DEFAULT 0,
  min_select  INT NOT NULL DEFAULT 0,
  max_select  INT NOT NULL DEFAULT 0
);
GO

CREATE TABLE dbo.modifier_options (
  option_id   INT IDENTITY(1,1) PRIMARY KEY,
  group_id    INT NOT NULL,
  option_name NVARCHAR(100) NOT NULL,
  extra_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  CONSTRAINT FK_modopt_group FOREIGN KEY (group_id) REFERENCES dbo.modifier_groups(group_id)
);
GO

CREATE TABLE dbo.menu_item_modifiers (
  menu_item_id INT NOT NULL,
  group_id     INT NOT NULL,
  CONSTRAINT PK_menu_item_modifiers PRIMARY KEY (menu_item_id, group_id),
  CONSTRAINT FK_mim_item  FOREIGN KEY (menu_item_id) REFERENCES dbo.menu_items(menu_item_id),
  CONSTRAINT FK_mim_group FOREIGN KEY (group_id)     REFERENCES dbo.modifier_groups(group_id)
);
GO

CREATE TABLE dbo.pricing_rules (
  rule_id      INT IDENTITY(1,1) PRIMARY KEY,
  menu_item_id INT NOT NULL,
  day_of_week  TINYINT NULL,   -- 0..6
  start_time   TIME NULL,
  end_time     TIME NULL,
  price        DECIMAL(12,2) NULL,  -- nếu NULL dùng discount
  discount_type NVARCHAR(10) NULL
    CONSTRAINT CK_pr_discount_type CHECK (discount_type IN (N'PERCENT',N'AMOUNT')),
  discount_value DECIMAL(12,2) NULL,
  active_from  DATE NULL,
  active_to    DATE NULL,
  CONSTRAINT FK_pr_item FOREIGN KEY (menu_item_id) REFERENCES dbo.menu_items(menu_item_id)
);
GO

CREATE TABLE dbo.recipes (
  recipe_id    INT IDENTITY(1,1) PRIMARY KEY,
  menu_item_id INT NOT NULL UNIQUE,
  version      INT NOT NULL DEFAULT 1,
  is_active    BIT NOT NULL DEFAULT 1,
  note         NVARCHAR(255),
  CONSTRAINT FK_recipe_item FOREIGN KEY (menu_item_id) REFERENCES dbo.menu_items(menu_item_id)
);
GO

CREATE TABLE dbo.recipe_items (
  recipe_item_id INT IDENTITY(1,1) PRIMARY KEY,
  recipe_id  INT NOT NULL,
  item_id    INT NOT NULL,
  qty        DECIMAL(12,3) NOT NULL,
  CONSTRAINT FK_ri_recipe FOREIGN KEY (recipe_id) REFERENCES dbo.recipes(recipe_id),
  CONSTRAINT FK_ri_item   FOREIGN KEY (item_id)   REFERENCES dbo.inventory_items(item_id)
);
GO

/* ========== Reservations ========== */
CREATE TABLE dbo.reservations (
  reservation_id   INT IDENTITY(1,1) PRIMARY KEY,
  customer_id      INT NULL,
  table_id         INT NULL,
  reservation_date DATE NOT NULL,
  reservation_time TIME NOT NULL,
  party_size       INT NOT NULL,
  status           NVARCHAR(20) NOT NULL DEFAULT N'PENDING'
    CONSTRAINT CK_res_status CHECK (status IN (N'PENDING',N'CONFIRMED',N'SEATED',N'NO_SHOW',N'CANCELLED')),
  special_requests NVARCHAR(255),
  created_by       INT NULL,
  deposit_amount   DECIMAL(12,2) NOT NULL DEFAULT 0,
  deposit_status   NVARCHAR(20) NOT NULL DEFAULT N'NONE'
    CONSTRAINT CK_res_deposit_status CHECK (deposit_status IN (N'NONE',N'PENDING',N'PAID',N'REFUNDED',N'FORFEITED')),
  confirmation_code NVARCHAR(50),
  channel          NVARCHAR(20) NOT NULL DEFAULT N'WALKIN'
    CONSTRAINT CK_res_channel CHECK (channel IN (N'PHONE',N'WALKIN',N'WEB',N'APP',N'OTHER')),
  created_at      DATETIME2(0) DEFAULT SYSDATETIME(),
  updated_at      DATETIME2(0) DEFAULT SYSDATETIME(),
  CONSTRAINT FK_res_customer FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id) ON DELETE SET NULL,
  CONSTRAINT FK_res_table FOREIGN KEY (table_id) REFERENCES dbo.dining_table(table_id) ON DELETE SET NULL,
  CONSTRAINT FK_res_creator FOREIGN KEY (created_by) REFERENCES dbo.users(user_id) ON DELETE SET NULL
);
GO

/* ========== Orders & Items ========== */
CREATE TABLE dbo.orders (
  order_id    BIGINT IDENTITY(1,1) PRIMARY KEY,
  order_code  NVARCHAR(30) UNIQUE,
  order_type  NVARCHAR(10) NOT NULL
    CONSTRAINT CK_order_type CHECK (order_type IN (N'DINE_IN',N'TAKEAWAY')),
  customer_id INT NULL,
  table_id    INT NULL,
  waiter_id   INT NULL,
  status      NVARCHAR(20) NOT NULL DEFAULT N'OPEN'
    CONSTRAINT CK_order_status CHECK (status IN (N'OPEN',N'SENT_TO_KITCHEN',N'COOKING',N'PARTIAL_READY',N'READY',N'SERVED',N'CANCELLED',N'SETTLED')),
  notes       NVARCHAR(255),
  opened_at   DATETIME2(0) DEFAULT SYSDATETIME(),
  closed_at   DATETIME2(0),
  CONSTRAINT FK_order_customer FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id) ON DELETE SET NULL,
  CONSTRAINT FK_order_table    FOREIGN KEY (table_id)    REFERENCES dbo.dining_table(table_id) ON DELETE SET NULL,
  CONSTRAINT FK_order_waiter   FOREIGN KEY (waiter_id)   REFERENCES dbo.staff(staff_id) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.order_items (
  order_item_id BIGINT IDENTITY(1,1) PRIMARY KEY,
  order_id      BIGINT NOT NULL,
  menu_item_id  INT NOT NULL,
  quantity      DECIMAL(10,2) NOT NULL,
  base_unit_price  DECIMAL(12,2) NOT NULL,
  final_unit_price DECIMAL(12,2) NOT NULL,
  course_no     TINYINT NOT NULL DEFAULT 1,
  priority      NVARCHAR(10) NOT NULL DEFAULT N'NORMAL'
    CONSTRAINT CK_oi_priority CHECK (priority IN (N'LOW',N'NORMAL',N'HIGH')),
  special_instructions NVARCHAR(255),
  status        NVARCHAR(12) NOT NULL DEFAULT N'NEW'
    CONSTRAINT CK_oi_status CHECK (status IN (N'NEW',N'SENT',N'COOKING',N'READY',N'SERVED',N'CANCELLED')),
  cancelled_by  INT NULL,
  cancel_reason NVARCHAR(255),
  served_by     INT NULL,
  served_at     DATETIME2(0),
  created_at    DATETIME2(0) DEFAULT SYSDATETIME(),
  CONSTRAINT FK_oi_order FOREIGN KEY (order_id) REFERENCES dbo.orders(order_id),
  CONSTRAINT FK_oi_item  FOREIGN KEY (menu_item_id) REFERENCES dbo.menu_items(menu_item_id),
  -- Đổi cả 2 FK bên dưới về NO ACTION để tránh multiple cascade paths
  CONSTRAINT FK_oi_cancel_by FOREIGN KEY (cancelled_by) REFERENCES dbo.users(user_id),
  CONSTRAINT FK_oi_served_by FOREIGN KEY (served_by)   REFERENCES dbo.users(user_id)
);
GO

CREATE TABLE dbo.order_item_modifiers (
  order_item_id BIGINT NOT NULL,
  option_id     INT NOT NULL,
  quantity      DECIMAL(10,2) NOT NULL DEFAULT 1,
  extra_price   DECIMAL(12,2) NOT NULL DEFAULT 0,
  CONSTRAINT PK_order_item_modifiers PRIMARY KEY (order_item_id, option_id),
  CONSTRAINT FK_oim_oi   FOREIGN KEY (order_item_id) REFERENCES dbo.order_items(order_item_id),
  CONSTRAINT FK_oim_opt  FOREIGN KEY (option_id)     REFERENCES dbo.modifier_options(option_id)
);
GO

/* ========== Kitchen Tickets ========== */
CREATE TABLE dbo.kitchen_tickets (
  kt_id           BIGINT IDENTITY(1,1) PRIMARY KEY,
  order_item_id   BIGINT NOT NULL,
  station         NVARCHAR(50),
  preparation_status NVARCHAR(12) NOT NULL DEFAULT N'RECEIVED'
    CONSTRAINT CK_kt_status CHECK (preparation_status IN (N'RECEIVED',N'COOKING',N'READY',N'PICKED',N'SERVED',N'CANCELLED')),
  received_time   DATETIME2(0) DEFAULT SYSDATETIME(),
  start_time      DATETIME2(0),
  ready_time      DATETIME2(0),
  picked_time     DATETIME2(0),
  served_time     DATETIME2(0),
  chef_id         INT NULL,
  CONSTRAINT FK_kt_oi   FOREIGN KEY (order_item_id) REFERENCES dbo.order_items(order_item_id),
  CONSTRAINT FK_kt_chef FOREIGN KEY (chef_id)       REFERENCES dbo.staff(staff_id) ON DELETE SET NULL
);
GO

/* ========== Table sessions & actions ========== */
CREATE TABLE dbo.table_session (
  table_session_id BIGINT IDENTITY(1,1) PRIMARY KEY,
  table_id     INT NOT NULL,
  open_time    DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
  close_time   DATETIME2(0),
  status       NVARCHAR(10) NOT NULL DEFAULT N'OPEN'
    CONSTRAINT CK_ts_status CHECK (status IN (N'OPEN',N'CLOSED')),
  current_order_id BIGINT NULL,
  CONSTRAINT FK_ts_table FOREIGN KEY (table_id) REFERENCES dbo.dining_table(table_id),
  CONSTRAINT FK_ts_order FOREIGN KEY (current_order_id) REFERENCES dbo.orders(order_id) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.table_action_log (
  action_id   BIGINT IDENTITY(1,1) PRIMARY KEY,
  action_type NVARCHAR(20) NOT NULL
    CONSTRAINT CK_tal_action CHECK (action_type IN (N'MERGE',N'SPLIT',N'MOVE',N'TRANSFER_ORDER')),
  src_table_id INT NULL,
  dst_table_id INT NULL,
  order_id     BIGINT NULL,
  actor_id     INT NULL,
  reason       NVARCHAR(255),
  created_at   DATETIME2(0) DEFAULT SYSDATETIME(),
  CONSTRAINT FK_tal_src   FOREIGN KEY (src_table_id) REFERENCES dbo.dining_table(table_id),
  CONSTRAINT FK_tal_dst   FOREIGN KEY (dst_table_id) REFERENCES dbo.dining_table(table_id),
  CONSTRAINT FK_tal_order FOREIGN KEY (order_id)     REFERENCES dbo.orders(order_id),
  CONSTRAINT FK_tal_actor FOREIGN KEY (actor_id)     REFERENCES dbo.users(user_id)
);
GO

/* ========== Vouchers / Bills / Payments / Invoices ========== */
CREATE TABLE dbo.vouchers (
  voucher_id     INT IDENTITY(1,1) PRIMARY KEY,
  code           NVARCHAR(50) NOT NULL UNIQUE,
  description    NVARCHAR(255),
  discount_type  NVARCHAR(10) NOT NULL
    CONSTRAINT CK_voucher_type CHECK (discount_type IN (N'PERCENT',N'AMOUNT')),
  discount_value DECIMAL(12,2) NOT NULL,
  valid_from     DATE,
  valid_to       DATE,
  usage_limit    INT,
  min_order_total DECIMAL(12,2) NOT NULL DEFAULT 0,
  status         NVARCHAR(20) NOT NULL DEFAULT N'ACTIVE'
    CONSTRAINT CK_voucher_status CHECK (status IN (N'ACTIVE',N'INACTIVE')),
  created_by     INT NULL,
  CONSTRAINT FK_voucher_creator FOREIGN KEY (created_by) REFERENCES dbo.users(user_id) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.bills (
  bill_id       BIGINT IDENTITY(1,1) PRIMARY KEY,
  order_id      BIGINT NOT NULL,
  bill_no       NVARCHAR(30) UNIQUE,
  status        NVARCHAR(12) NOT NULL DEFAULT N'PROFORMA'
    CONSTRAINT CK_bill_status CHECK (status IN (N'PROFORMA',N'FINAL',N'VOID',N'REFUNDED')),
  subtotal      DECIMAL(12,2) NOT NULL DEFAULT 0,
  discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  tax_amount    DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_amount  DECIMAL(12,2) NOT NULL DEFAULT 0,
  vat_rate      DECIMAL(5,2)  NOT NULL DEFAULT 0,
  created_by    INT NULL,
  created_at    DATETIME2(0) DEFAULT SYSDATETIME(),
  finalized_at  DATETIME2(0),
  CONSTRAINT FK_bill_order   FOREIGN KEY (order_id)  REFERENCES dbo.orders(order_id),
  CONSTRAINT FK_bill_creator FOREIGN KEY (created_by) REFERENCES dbo.users(user_id) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.bill_items (
  bill_item_id  BIGINT IDENTITY(1,1) PRIMARY KEY,
  bill_id       BIGINT NOT NULL,
  order_item_id BIGINT NOT NULL,
  quantity      DECIMAL(10,2) NOT NULL,
  unit_price    DECIMAL(12,2) NOT NULL,
  line_total    DECIMAL(12,2) NOT NULL,
  CONSTRAINT FK_bi_bill FOREIGN KEY (bill_id) REFERENCES dbo.bills(bill_id),
  CONSTRAINT FK_bi_oi   FOREIGN KEY (order_item_id) REFERENCES dbo.order_items(order_item_id)
);
GO

CREATE TABLE dbo.payments (
  payment_id   BIGINT IDENTITY(1,1) PRIMARY KEY,
  bill_id      BIGINT NOT NULL,
  method       NVARCHAR(15) NOT NULL
    CONSTRAINT CK_payment_method CHECK (method IN (N'CASH',N'CARD',N'ONLINE',N'TRANSFER',N'VOUCHER')),
  amount       DECIMAL(12,2) NOT NULL,
  provider     NVARCHAR(50),
  transaction_id NVARCHAR(100),
  status       NVARCHAR(12) NOT NULL DEFAULT N'PENDING'
    CONSTRAINT CK_payment_status CHECK (status IN (N'PENDING',N'SUCCESS',N'FAILED',N'REFUNDED',N'VOIDED')),
  paid_at      DATETIME2(0),
  processed_by INT NULL,
  CONSTRAINT FK_payment_bill  FOREIGN KEY (bill_id) REFERENCES dbo.bills(bill_id),
  CONSTRAINT FK_payment_staff FOREIGN KEY (processed_by) REFERENCES dbo.staff(staff_id) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.voucher_redemptions (
  redemption_id BIGINT IDENTITY(1,1) PRIMARY KEY,
  voucher_id   INT NOT NULL,
  customer_id  INT NULL,
  bill_id      BIGINT NULL,
  redeemed_at  DATETIME2(0) DEFAULT SYSDATETIME(),
  amount       DECIMAL(12,2) NOT NULL DEFAULT 0,
  CONSTRAINT FK_vr_voucher  FOREIGN KEY (voucher_id) REFERENCES dbo.vouchers(voucher_id),
  CONSTRAINT FK_vr_customer FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id) ON DELETE SET NULL,
  CONSTRAINT FK_vr_bill     FOREIGN KEY (bill_id)     REFERENCES dbo.bills(bill_id) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.invoices (
  invoice_id BIGINT IDENTITY(1,1) PRIMARY KEY,
  bill_id    BIGINT NOT NULL,
  invoice_no NVARCHAR(50) UNIQUE,
  pdf_url    NVARCHAR(255),
  issued_at  DATETIME2(0) DEFAULT SYSDATETIME(),
  CONSTRAINT FK_invoices_bill FOREIGN KEY (bill_id) REFERENCES dbo.bills(bill_id)
);
GO

/* ========== Shifts ========== */
CREATE TABLE dbo.shift_schedule (
  shift_id   INT IDENTITY(1,1) PRIMARY KEY,
  staff_id   INT NOT NULL,
  shift_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time   TIME NOT NULL,
  status     NVARCHAR(12) NOT NULL DEFAULT N'PLANNED'
    CONSTRAINT CK_shift_status CHECK (status IN (N'PLANNED',N'CHECKIN',N'CHECKOUT',N'ABSENT',N'CANCELLED')),
  created_by INT NULL,
  CONSTRAINT FK_shift_staff   FOREIGN KEY (staff_id)   REFERENCES dbo.staff(staff_id),
  CONSTRAINT FK_shift_creator FOREIGN KEY (created_by) REFERENCES dbo.users(user_id) ON DELETE SET NULL
);
GO

/* ========== Audit Log ========== */
CREATE TABLE dbo.audit_log (
  log_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
  user_id    INT NULL,
  action     NVARCHAR(100),
  table_name NVARCHAR(100),
  record_id  BIGINT,
  old_values NVARCHAR(MAX) NULL,
  new_values NVARCHAR(MAX) NULL,
  timestamp  DATETIME2(0) DEFAULT SYSDATETIME(),
  ip_address NVARCHAR(64),
  CONSTRAINT FK_audit_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id),
  CONSTRAINT CK_audit_old_json CHECK (old_values IS NULL OR ISJSON(old_values)=1),
  CONSTRAINT CK_audit_new_json CHECK (new_values IS NULL OR ISJSON(new_values)=1)
);
GO

/* ========== Indexes hữu ích ========== */
CREATE INDEX IX_orders_status      ON dbo.orders(status);
CREATE INDEX IX_order_items_status ON dbo.order_items(status);
CREATE INDEX IX_kitchen_ready      ON dbo.kitchen_tickets(preparation_status, ready_time);
CREATE INDEX IX_bills_status       ON dbo.bills(status, created_at);
CREATE INDEX IX_payments_bill      ON dbo.payments(bill_id, status);
CREATE INDEX IX_reservations_date  ON dbo.reservations(status, reservation_date);
GO