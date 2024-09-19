//namespace my.bookshop;

context my.bookshop {

  entity Books {
    key ID    : Integer;
        title : String;
        stock : Integer;
  }

  entity CustomerTable {
    key Customer_ID  : Integer;
        CustomerName : String(30);
        Country      : String(10);
  }

  entity CustomerRefTable {
    key Customer_ID   : Association to CustomerTable;
        ContactFreq   : String;
        ContactMethod : String;


  }

  entity SalesTable {
    key Order_ID    : Integer;
        Customer_ID : Integer;
        Sold_Qty    : Integer;

  }

  entity salesRefTable {
    key Order_ID   : Association to SalesTable;
        Return_Qty : Integer;

  }


  entity Table1 {
    key ID   : Integer;
        Name : String(10);
  }


  entity UserMaster {
    key UserID         : String(40);
        EmailID        : String(40);
        FirstName      : String(40);
        LastName       : String(40);
        UserAssignment : Composition of many UserAssignment
                           on UserAssignment.UserID = $self;
  }

  entity UserAssignment {
    key ID                     : Integer;
        UserID                 : Association to UserMaster;
        EmailID                : String(40);
        CompanyCode            : String(10);
        CompanyCodeDescription : String(200);
        PurchaseOrg            : String(10);
        PurchaseOrgDescription : String(200);
  }

  entity Products {
    key ProductID   : Integer;
        ProductName : String;
        Category    : String;
  }

  entity Sales {
    key SaleID       : Integer;
        ProductID    : Association to Products;
        SaleDate     : DateTime;
        QuantitySold : Integer;
  }


  entity Stock {
    key ID              : Integer;
        ProductID       : Association to Products;
        QuantityInStock : Integer;
  }

  entity Promotion {
    key PromotionID     : Integer;
        ProductID       : Association to Products;
        PromotionStatus : String;
  }


  entity Risks {
    title                   : String(100);
    owner                   : String;
    //prio                     : Association to Priority;
    descr                   : String;
    miti                    : Association to miti;
    impact                  : Integer;
    bp                      : Association to bp; // <-- uncomment this line
    virtual criticality     : Integer;
    virtual PrioCriticality : Integer;
  }

  entity miti {
    descr    : String;
    owner    : String;
    timeline : String;
    Risks    : Composition of many Risks
                 on Risks.miti = $self;

  }

  entity bp {
    key BusinessPartner : Integer;
        FirstName       : String;
        LastName        : String;


  }

  entity InvoiceLine {
    key partID              : String;
        purchaseOrderNumber : Integer;
        BTP_IBDNumber       : String;
        SAP_LineID_IBD      : String;
        BTP_GRNumber        : String;
  }

  entity A_PurchaseOrder {
    key PurchaseOrder : String;
  }

  entity A_PurchaseOrderItem {
    key PurchaseOrder     : Association to A_PurchaseOrder;
    key PurchaseOrderItem : String;
        Plant             : String;
  }

  entity ZCROSSREF {
    SAP_Code : String;

  }

}
