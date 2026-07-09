DROP DATABASE IF EXISTS Hospital_Management;
CREATE DATABASE Hospital_Management ;
USE Hospital_Management;


CREATE TABLE Departments (
    DepartmentID    INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName  VARCHAR(100) NOT NULL UNIQUE,
    Location        VARCHAR(100),
    ExtensionNumber VARCHAR(10)
);

CREATE TABLE Doctors (
    DoctorID         INT AUTO_INCREMENT PRIMARY KEY,
    FirstName        VARCHAR(50) NOT NULL,
    LastName         VARCHAR(50) NOT NULL,
    Specialization   VARCHAR(100) NOT NULL,
    Phone            VARCHAR(15),
    Email            VARCHAR(100) UNIQUE,
    Salary           DECIMAL(10,2) CHECK (Salary >= 0),
    PrimaryDeptID    INT,
    HireDate         DATE DEFAULT (CURRENT_DATE),
    IsActive         BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_doctors_dept FOREIGN KEY (PrimaryDeptID)
        REFERENCES Departments(DepartmentID) ON DELETE SET NULL
);

CREATE TABLE Doctor_Department (
    DoctorID     INT,
    DepartmentID INT,
    PRIMARY KEY (DoctorID, DepartmentID),
    CONSTRAINT fk_dd_doctor FOREIGN KEY (DoctorID)
        REFERENCES Doctors(DoctorID) ON DELETE CASCADE,
    CONSTRAINT fk_dd_dept FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID) ON DELETE CASCADE
);

CREATE TABLE Staff (
    StaffID      INT AUTO_INCREMENT PRIMARY KEY,
    FirstName    VARCHAR(50) NOT NULL,
    LastName     VARCHAR(50) NOT NULL,
    Role         ENUM('Nurse','Receptionist','Lab Technician','Pharmacist','Admin','Janitor','Security') NOT NULL,
    DepartmentID INT,
    Phone        VARCHAR(15),
    Email        VARCHAR(100) UNIQUE,
    Salary       DECIMAL(10,2) CHECK (Salary >= 0),
    HireDate     DATE DEFAULT (CURRENT_DATE),
    IsActive     BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_staff_dept FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID) ON DELETE SET NULL
);

CREATE TABLE Patients (
    PatientID    INT AUTO_INCREMENT PRIMARY KEY,
    FirstName    VARCHAR(50) NOT NULL,
    LastName     VARCHAR(50) NOT NULL,
    Gender       ENUM('Male','Female','Other') NOT NULL,
    DOB          DATE NOT NULL,
    Phone        VARCHAR(15),
    Email        VARCHAR(100),
    Address      VARCHAR(255),
    BloodGroup   ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-'),
    RegisteredAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE EmergencyContacts (
    ContactID    INT AUTO_INCREMENT PRIMARY KEY,
    PatientID    INT NOT NULL,
    ContactName  VARCHAR(100) NOT NULL,
    Relationship VARCHAR(50),
    Phone        VARCHAR(15) NOT NULL,
    CONSTRAINT fk_ec_patient FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID) ON DELETE CASCADE
);

CREATE TABLE Insurance (
    InsuranceID    INT AUTO_INCREMENT PRIMARY KEY,
    PatientID      INT NOT NULL,
    ProviderName   VARCHAR(100) NOT NULL,
    PolicyNumber   VARCHAR(50) NOT NULL UNIQUE,
    CoverageAmount DECIMAL(12,2) CHECK (CoverageAmount >= 0),
    ValidTill      DATE,
    CONSTRAINT fk_insurance_patient FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID) ON DELETE CASCADE
);
CREATE TABLE Rooms (
    RoomID       INT AUTO_INCREMENT PRIMARY KEY,
    RoomNumber   VARCHAR(10) NOT NULL UNIQUE,
    RoomType     ENUM('General','Private','Semi-Private','ICU','Operation Theatre') NOT NULL,
    RoomCharge   DECIMAL(10,2) NOT NULL CHECK (RoomCharge >= 0),
    Availability ENUM('Available','Occupied','Maintenance') DEFAULT 'Available'
);

CREATE TABLE Admissions (
    AdmissionID    INT AUTO_INCREMENT PRIMARY KEY,
    PatientID      INT NOT NULL,
    RoomID         INT NOT NULL,
    AttendingDoctorID INT,
    AdmissionDate  DATE NOT NULL,
    DischargeDate  DATE,
    Reason         VARCHAR(255),
    CONSTRAINT fk_admissions_patient FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID) ON DELETE CASCADE,
    CONSTRAINT fk_admissions_room FOREIGN KEY (RoomID)
        REFERENCES Rooms(RoomID) ON DELETE RESTRICT,
    CONSTRAINT fk_admissions_doctor FOREIGN KEY (AttendingDoctorID)
        REFERENCES Doctors(DoctorID) ON DELETE SET NULL,
    CONSTRAINT chk_discharge_after_admission CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate)
);
CREATE TABLE Appointments (
    AppointmentID   INT AUTO_INCREMENT PRIMARY KEY,
    PatientID       INT NOT NULL,
    DoctorID        INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Status          ENUM('Pending','Confirmed','Completed','Cancelled','No-Show') DEFAULT 'Pending',
    Notes           VARCHAR(255),
    CONSTRAINT fk_appt_patient FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID) ON DELETE CASCADE,
    CONSTRAINT fk_appt_doctor FOREIGN KEY (DoctorID)
        REFERENCES Doctors(DoctorID) ON DELETE CASCADE,
    CONSTRAINT uq_doctor_slot UNIQUE (DoctorID, AppointmentDate, AppointmentTime)
);

CREATE TABLE MedicalRecords (
    RecordID      INT AUTO_INCREMENT PRIMARY KEY,
    PatientID     INT NOT NULL,
    DoctorID      INT NOT NULL,
    AppointmentID INT,
    VisitDate     DATE NOT NULL,
    Diagnosis     VARCHAR(255),
    Treatment     VARCHAR(255),
    Notes         TEXT,
    CONSTRAINT fk_mr_patient FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID) ON DELETE CASCADE,
    CONSTRAINT fk_mr_doctor FOREIGN KEY (DoctorID)
        REFERENCES Doctors(DoctorID) ON DELETE RESTRICT,
    CONSTRAINT fk_mr_appointment FOREIGN KEY (AppointmentID)
        REFERENCES Appointments(AppointmentID) ON DELETE SET NULL
);
CREATE TABLE Suppliers (
    SupplierID   INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    ContactEmail VARCHAR(100),
    Phone        VARCHAR(15),
    Address      VARCHAR(255)
);

CREATE TABLE Medicines (
    MedicineID   INT AUTO_INCREMENT PRIMARY KEY,
    MedicineName VARCHAR(100) NOT NULL,
    Category     VARCHAR(50),
    Price        DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    Stock        INT NOT NULL DEFAULT 0 CHECK (Stock >= 0),
    ExpiryDate   DATE
);

CREATE TABLE Medicine_Purchases (
    PurchaseID   INT AUTO_INCREMENT PRIMARY KEY,
    MedicineID   INT NOT NULL,
    SupplierID   INT NOT NULL,
    Quantity     INT NOT NULL CHECK (Quantity > 0),
    UnitCost     DECIMAL(10,2) NOT NULL CHECK (UnitCost >= 0),
    PurchaseDate DATE DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_purchase_medicine FOREIGN KEY (MedicineID)
        REFERENCES Medicines(MedicineID) ON DELETE CASCADE,
    CONSTRAINT fk_purchase_supplier FOREIGN KEY (SupplierID)
        REFERENCES Suppliers(SupplierID) ON DELETE RESTRICT
);

CREATE TABLE Prescriptions (
    PrescriptionID   INT AUTO_INCREMENT PRIMARY KEY,
    PatientID        INT NOT NULL,
    DoctorID         INT NOT NULL,
    PrescriptionDate DATE NOT NULL,
    CONSTRAINT fk_presc_patient FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID) ON DELETE CASCADE,
    CONSTRAINT fk_presc_doctor FOREIGN KEY (DoctorID)
        REFERENCES Doctors(DoctorID) ON DELETE RESTRICT
);


CREATE TABLE Prescription_Items (
    PrescriptionItemID INT AUTO_INCREMENT PRIMARY KEY,
    PrescriptionID      INT NOT NULL,
    MedicineID           INT NOT NULL,
    Dosage               VARCHAR(100) NOT NULL,
    DurationDays          INT CHECK (DurationDays > 0),
    Quantity              INT NOT NULL CHECK (Quantity > 0),
    CONSTRAINT fk_pi_prescription FOREIGN KEY (PrescriptionID)
        REFERENCES Prescriptions(PrescriptionID) ON DELETE CASCADE,
    CONSTRAINT fk_pi_medicine FOREIGN KEY (MedicineID)
        REFERENCES Medicines(MedicineID) ON DELETE RESTRICT
);

CREATE TABLE LabTests (
    TestID   INT AUTO_INCREMENT PRIMARY KEY,
    TestName VARCHAR(100) NOT NULL UNIQUE,
    Price    DECIMAL(10,2) NOT NULL CHECK (Price >= 0)
);

CREATE TABLE LabTestOrders (
    OrderID   INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID  INT NOT NULL,
    TestID    INT NOT NULL,
    OrderDate DATE NOT NULL,
    Status    ENUM('Ordered','Sample Collected','Completed','Cancelled') DEFAULT 'Ordered',
    CONSTRAINT fk_lto_patient FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID) ON DELETE CASCADE,
    CONSTRAINT fk_lto_doctor FOREIGN KEY (DoctorID)
        REFERENCES Doctors(DoctorID) ON DELETE RESTRICT,
    CONSTRAINT fk_lto_test FOREIGN KEY (TestID)
        REFERENCES LabTests(TestID) ON DELETE RESTRICT
);

CREATE TABLE LabTestResults (
    ResultID   INT AUTO_INCREMENT PRIMARY KEY,
    OrderID    INT NOT NULL UNIQUE,
    ResultText TEXT,
    ResultDate DATE,
    TechnicianID INT,
    CONSTRAINT fk_ltr_order FOREIGN KEY (OrderID)
        REFERENCES LabTestOrders(OrderID) ON DELETE CASCADE,
    CONSTRAINT fk_ltr_staff FOREIGN KEY (TechnicianID)
        REFERENCES Staff(StaffID) ON DELETE SET NULL
);

CREATE TABLE Ambulances (
    AmbulanceID  INT AUTO_INCREMENT PRIMARY KEY,
    VehicleNumber VARCHAR(20) NOT NULL UNIQUE,
    DriverName   VARCHAR(100),
    DriverPhone  VARCHAR(15),
    Status       ENUM('Available','On Duty','Maintenance') DEFAULT 'Available'
);

CREATE TABLE Ambulance_Requests (
    RequestID    INT AUTO_INCREMENT PRIMARY KEY,
    PatientID    INT,
    AmbulanceID  INT NOT NULL,
    PickupAddress VARCHAR(255) NOT NULL,
    RequestTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status       ENUM('Requested','Dispatched','Completed','Cancelled') DEFAULT 'Requested',
    CONSTRAINT fk_ar_patient FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID) ON DELETE SET NULL,
    CONSTRAINT fk_ar_ambulance FOREIGN KEY (AmbulanceID)
        REFERENCES Ambulances(AmbulanceID) ON DELETE RESTRICT
);

CREATE TABLE Billing (
    BillID        INT AUTO_INCREMENT PRIMARY KEY,
    PatientID     INT NOT NULL,
    BillDate      DATE NOT NULL,
    PaymentStatus ENUM('Paid','Pending','Partially Paid','Cancelled') DEFAULT 'Pending',
    PaymentMethod ENUM('Cash','Card','UPI','Insurance','Net Banking'),
    CONSTRAINT fk_billing_patient FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID) ON DELETE CASCADE
);


CREATE TABLE Billing_Items (
    BillItemID  INT AUTO_INCREMENT PRIMARY KEY,
    BillID      INT NOT NULL,
    Description VARCHAR(150) NOT NULL,
    ChargeType  ENUM('Consultation','Room','Medicine','Lab Test','Surgery','Other') NOT NULL,
    Amount      DECIMAL(10,2) NOT NULL CHECK (Amount >= 0),
    CONSTRAINT fk_bi_bill FOREIGN KEY (BillID)
        REFERENCES Billing(BillID) ON DELETE CASCADE
);


CREATE TABLE Staff_Shifts (
    ShiftID   INT AUTO_INCREMENT PRIMARY KEY,
    StaffID   INT NOT NULL,
    ShiftDate DATE NOT NULL,
    ShiftType ENUM('Morning','Evening','Night') NOT NULL,
    CONSTRAINT fk_shift_staff FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID) ON DELETE CASCADE,
    CONSTRAINT uq_staff_shift UNIQUE (StaffID, ShiftDate, ShiftType)
);


CREATE TABLE Feedback (
    FeedbackID   INT AUTO_INCREMENT PRIMARY KEY,
    PatientID    INT NOT NULL,
    DoctorID     INT,
    Rating       TINYINT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comments     VARCHAR(255),
    FeedbackDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_feedback_patient FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID) ON DELETE CASCADE,
    CONSTRAINT fk_feedback_doctor FOREIGN KEY (DoctorID)
        REFERENCES Doctors(DoctorID) ON DELETE SET NULL
);

CREATE TABLE Users (
    UserID       INT AUTO_INCREMENT PRIMARY KEY,
    Username     VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Role         ENUM('Admin','Doctor','Staff','Receptionist') NOT NULL,
    DoctorID     INT,
    StaffID      INT,
    IsActive     BOOLEAN DEFAULT TRUE,
    CreatedAt    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_doctor FOREIGN KEY (DoctorID)
        REFERENCES Doctors(DoctorID) ON DELETE SET NULL,
    CONSTRAINT fk_users_staff FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID) ON DELETE SET NULL
);


-- INDEXES for common lookups
CREATE INDEX idx_appt_patient       ON Appointments(PatientID);
CREATE INDEX idx_appt_doctor        ON Appointments(DoctorID);
CREATE INDEX idx_appt_date          ON Appointments(AppointmentDate);
CREATE INDEX idx_admissions_patient ON Admissions(PatientID);
CREATE INDEX idx_billing_patient    ON Billing(PatientID);
CREATE INDEX idx_prescriptions_patient ON Prescriptions(PatientID);
CREATE INDEX idx_labtestorders_patient ON LabTestOrders(PatientID);
CREATE INDEX idx_medrecords_patient  ON MedicalRecords(PatientID);

DELIMITER $$
CREATE TRIGGER trg_reduce_medicine_stock
AFTER INSERT ON Prescription_Items
FOR EACH ROW
BEGIN
    UPDATE Medicines
    SET Stock = Stock - NEW.Quantity
    WHERE MedicineID = NEW.MedicineID;
END$$

CREATE TRIGGER trg_increase_medicine_stock
AFTER INSERT ON Medicine_Purchases
FOR EACH ROW
BEGIN
    UPDATE Medicines
    SET Stock = Stock + NEW.Quantity
    WHERE MedicineID = NEW.MedicineID;
END$$

CREATE TRIGGER trg_free_room_on_discharge
AFTER UPDATE ON Admissions
FOR EACH ROW
BEGIN
    IF NEW.DischargeDate IS NOT NULL AND OLD.DischargeDate IS NULL THEN
        UPDATE Rooms SET Availability = 'Available' WHERE RoomID = NEW.RoomID;
    END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------
-- VIEW: patient billing summary (total billed vs paid status)
-- ---------------------------------------------------------
CREATE VIEW vw_patient_billing_summary AS
SELECT
    b.BillID,
    CONCAT(p.FirstName,' ',p.LastName) AS PatientName,
    b.BillDate,
    b.PaymentStatus,
    SUM(bi.Amount) AS TotalAmount
FROM Billing b
JOIN Patients p ON p.PatientID = b.PatientID
LEFT JOIN Billing_Items bi ON bi.BillID = b.BillID
GROUP BY b.BillID, PatientName, b.BillDate, b.PaymentStatus;

-- ---------------------------------------------------------
-- STORED PROCEDURE: full visit history for a given patient
-- ---------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE sp_patient_visit_history(IN in_patient_id INT)
BEGIN
    SELECT
        mr.VisitDate,
        CONCAT(d.FirstName,' ',d.LastName) AS Doctor,
        d.Specialization,
        mr.Diagnosis,
        mr.Treatment
    FROM MedicalRecords mr
    JOIN Doctors d ON d.DoctorID = mr.DoctorID
    WHERE mr.PatientID = in_patient_id
    ORDER BY mr.VisitDate DESC;
END$$
DELIMITER ;