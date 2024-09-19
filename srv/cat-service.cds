using my.bookshop as my from '../db/data-model';
using {API_BUSINESS_PARTNER as external} from '../srv/external/API_BUSINESS_PARTNER.csn';


service CatalogService {
    entity Books               as projection on my.Books;
    entity CustomerTable       as projection on my.CustomerTable;
    entity CustomerRefTable    as projection on my.CustomerRefTable;
    entity SalesTable          as projection on my.SalesTable;
    entity salesRefTable       as projection on my.salesRefTable;
    entity Table1              as projection on my.Table1;
    entity UserAssignment      as projection on my.UserAssignment;
    entity Products            as projection on my.Products;
    entity Sales               as projection on my.Sales;
    entity Stock               as projection on my.Stock;
    entity Promotion           as projection on my.Promotion;
    entity bp                  as projection on my.bp;
    entity Risks               as projection on my.Risks;
    entity miti                as projection on my.miti;
    entity InvoiceLine         as projection on my.InvoiceLine;
    entity A_PurchaseOrder     as projection on my.A_PurchaseOrder;
    entity A_PurchaseOrderItem as projection on my.A_PurchaseOrderItem;
    entity ZCROSSREF           as projection on my.ZCROSSREF;
    action GET_Currentuser(UserID : String(40)) returns Boolean;

    //find current user using cds view.
    /*entity Get_Orders_Detail as
    select from UserAssignment as T1{
        T1.ID,
        T1.EmailID,
        T1.UserID.UserID as user,
        T1.CompanyCode,
        T1.CompanyCodeDescription,
        T1.PurchaseOrg,
        T1.PurchaseOrgDescription
    }
    where
     upper(
        T1.UserID.UserID
      ) = upper($user);*/

    //find Hardcode current user using cds view.
    entity Get_Orders_Detail   as
        select from UserAssignment as T1 {
            T1.ID,
            T1.EmailID,
            T1.UserID.UserID as user,
            T1.CompanyCode,
            T1.CompanyCodeDescription,
            T1.PurchaseOrg,
            T1.PurchaseOrgDescription
        }
        where
            upper(
                T1.UserID.UserID
            ) = upper('Kalyani');


    entity Get_Productstatus   as
        select from Products as P
        inner join Stock as S
            on P.ProductID = S.ID
        left join Sales as S1
            on P.ProductID = S1.SaleID
        left join Promotion as P1
            on P.ProductID = P1.PromotionID
        {
            P.ProductID,
            P.ProductName,
            S.QuantityInStock,
            cast(
                case
                    when
                        P1.PromotionStatus = 'Active'
                    then
                        'on promotion'
                    when
                        S.QuantityInStock > 0
                    then
                        'In Stock'
                    else
                        'Out of stock'
                end as String
            ) as Status

        };


    entity Get_CheckStock      as
        select from Get_Productstatus as Pr {
            Pr.ProductID,
            Pr.ProductName
        }
        where
            QuantityInStock < 10;


    entity Get_Statusproducts  as
        select from Get_Productstatus as P2 {
            P2.ProductID,
            P2.ProductName,
            P2.Status
        }
        where
            P2.Status in (
                'Out of stock', 'on promotion'
            )
        group by
            P2.ProductID,
            P2.ProductName,
            P2.Status;


    entity Get_SalesStatus     as
        select from Sales as S1
        inner join Get_Productstatus as Pr1
            on S1.SaleID = Pr1.ProductID
        {

            Pr1.ProductID,
            Pr1.ProductName,
            SUM(
                S1.QuantitySold
            ) as TotalSold : Integer

        }
        group by
            Pr1.ProductID,
            Pr1.ProductName;


    entity Get_Status          as
        select from Sales as S2
        inner join Get_Productstatus as Pr2
            on S2.SaleID = Pr2.ProductID
        {

            Pr2.ProductID,
            Pr2.ProductName,
            Pr2.Status

        }
        where
            Pr2.Status = 'on promotion'
        group by
            Pr2.ProductID,
            Pr2.ProductName,
            Pr2.Status;

    entity BusinessPartners    as
        projection on external.A_BusinessPartner {
            key BusinessPartner,
                BusinessPartnerFullName as FullName,
        }

    //Convert a numeric field to a string and aggregate it.
    entity Get_stock_GR        as
        select from InvoiceLine as T0
        inner join A_PurchaseOrderItem as T1
            on T0.purchaseOrderNumber = T1.PurchaseOrder.PurchaseOrder
        left join ZCROSSREF as T2
            on T1.Plant = T2.SAP_Code
        {
            T0.purchaseOrderNumber,
            cast(
                MAX(
                    T0.BTP_IBDNumber
                ) as String
            ) as IBD_NO,
            cast(
                MAX(
                    T0.SAP_LineID_IBD
                ) as String
            ) as IBD_LINE

        }
        where
                ifnull(
                T2.SAP_Code, 'X'
            ) =  'X'
            and ifnull(
                T0.BTP_GRNumber, ''
            ) <> ''
            and ifnull(
                T0.BTP_IBDNumber, ''
            ) <> ''
            and ifnull(
                T0.SAP_LineID_IBD, ''
            ) <> ''
        group by
            T0.purchaseOrderNumber;


    // Create a new field that categorizes orders based on the presence of BTP_GRNumber.
    entity Get_Stock_GR1       as
        select from InvoiceLine as T0
        inner join A_PurchaseOrderItem as T1
            on T0.purchaseOrderNumber = T1.PurchaseOrder.PurchaseOrder
        left join ZCROSSREF as T2
            on T1.Plant = T2.SAP_Code
        {
            T0.purchaseOrderNumber,
            cast(
                case
                    when
                        ifnull(
                            T0.BTP_GRNumber, ''
                        ) = ''
                    then
                        'No GR Number'
                    else
                        'Has GR Number'
                end as String
            ) as GR_Status
        }
        where
                ifnull(
                T2.SAP_Code, 'X'
            ) =  'X'
            and ifnull(
                T0.BTP_IBDNumber, ''
            ) <> ''
            and ifnull(
                T0.SAP_LineID_IBD, ''
            ) <> ''
        group by
            T0.purchaseOrderNumber,
            T0.BTP_GRNumber;


//Find the maximum value of BTP_IBDNumber for each purchaseOrderNumber.
    entity Get_stock_GR2       as
        select from InvoiceLine as T0
        inner join A_PurchaseOrderItem as T1
            on T0.purchaseOrderNumber = T1.PurchaseOrder.PurchaseOrder
        left join ZCROSSREF as T2
            on T1.Plant = T2.SAP_Code
        {
            T0.purchaseOrderNumber,
            cast(
                MAX(
                    T0.BTP_IBDNumber
                ) as String
            ) as Max_IBD_NO
        }
        where
                ifnull(
                T2.SAP_Code, 'X'
            ) =  'X'
            and ifnull(
                T0.BTP_GRNumber, ''
            ) <> ''
            and ifnull(
                T0.BTP_IBDNumber, ''
            ) <> ''
            and ifnull(
                T0.SAP_LineID_IBD, ''
            ) <> ''
        group by
            T0.purchaseOrderNumber;


//Replace null values with a default value in the result set.
}
