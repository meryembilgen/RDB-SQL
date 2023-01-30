CREATE DATABASE Manufacturer

USE Manufacturer

CREATE TABLE [Product] (
    [prod_id] INT PRIMARY KEY NOT NULL,
    [prod_name] VARCHAR(50) NOT NULL,
    [quantity] INT
);

CREATE TABLE [Component] (
    [comp_id] INT PRIMARY KEY NOT NULL,
    [comp_name] VARCHAR(50) NOT NULL,
    [description] VARCHAR(50) NULL,
    [quantity_comp] INT NOT NULL
);


CREATE TABLE [Supplier] (
    [supp_id] INT PRIMARY KEY NOT NULL,
    [supp_name] VARCHAR(50) NOT NULL,
    [supp_location] VARCHAR(50) NOT NULL,
    [supp_country] VARCHAR(50) NOT NULL,
    [is_active] BIT NOT NULL
);


CREATE TABLE [Prod_Comp] (
    [prod_id] INT NOT NULL,
    [comp_id] INT NOT NULL,
    [quantity_comp] INT NOT NULL,
    PRIMARY KEY ([prod_id], [comp_id])
);


CREATE TABLE [Comp_Supp] (
    [supp_id] INT NOT NULL,
    [comp_id] INT NOT NULL,
    [order_date] DATE NULL,
    [quantity] INT NULL,
    PRIMARY KEY ([supp_id], [comp_id])
);



ALTER TABLE Prod_Comp 
ADD CONSTRAINT FK_Product FOREIGN KEY (prod_id) REFERENCES Product (prod_id);

ALTER TABLE Prod_Comp
ADD CONSTRAINT FK_Component FOREIGN KEY (comp_id) REFERENCES Component (comp_id);

ALTER TABLE Comp_Supp 
ADD CONSTRAINT FK_Supplier FOREIGN KEY (supp_id) REFERENCES Supplier (supp_id);

ALTER TABLE Comp_Supp
ADD CONSTRAINT FK_Component_Supp FOREIGN KEY (comp_id) REFERENCES Component (comp_id);



