
const cds = require('@sap/cds');
const util = require('./util/util');
const { Console } = require('console');


module.exports = cds.service.impl(async function () {

    const { Table1, GET_CurrentUser ,UserMaster,BusinessPartners} = cds.entities('my.bookshop')


    this.before('CREATE', 'Table1', async (req) => {

        const tx = cds.tx(req);
        if (!req.data.ID) {
            req.data.ID = await autoID('Table1', 'ID', tx);
            console.log(req.data);
        }
    });



    // find  when we have to fetch ui side current user using node.js

    //         this.on('READ', 'UserMaster', async (req) => {
    //             const UserID  = req.user.id;
    //             return SELECT.from('UserMaster').where({ UserID  });
    //         });


    // find hardcode current user using node.js 

    this.on('GET_Currentuser', async (req) => {
        try {
            const inputUserID = req.data.UserID;  
            const hardcodedUserID = "kalyani";   

            if (inputUserID === hardcodedUserID) {

                const result = await cds.run(SELECT.one.from(UserMaster).where({ UserID: hardcodedUserID }));
                console.log(" Fetch User :", JSON.stringify(result));

                         
            } else {
               console.log('Error');
            }
         return true;  
        } catch (error) {
            console.error("Error:", error);

        }
        return false;
    });



    
    //connect to remote service to read data from external service.
    const BPsrv = await cds.connect.to("API_BUSINESS_PARTNER");

    /**
     * Event-handler for read-events on the BusinessPartners entity.
     * Each request to the API Business Hub requires the apikey in the header.
     */
    this.on("READ", BusinessPartners, async (req) => {
        // The API Sandbox returns alot of business partners with empty names.
        // We don't want them in our application
        req.query.where("LastName <> '' and FirstName <> '' ");

        return await BPsrv.transaction(req).send({
            query: req.query,
            headers: {
                apikey: process.env.apikey,
            },
        });
    });

});
