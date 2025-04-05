## IWPMS - Intelligent Work Permit Management System Deployment Steps
### *Pre-Requisites*

---

### Infrastructure
1. Machine(s) either bare metal or virtual to run web server and database server
    - Machine should support running debian based linux distro (ubuntu is recommended)
### Softwares with Recommended versions
1. Ubuntu operation system, Version: 24.04.1 LTS
2. Mongo database server, Version: 7.0.7
3. Docker, Version: 27.4.0
4. Docker buildx, Version: 0.19.2
5. Docker compose, Version: 2.31.0
6. Mongo shell, Version: 2.2.0

---

### Installation steps
#### System setup
1. Setup and configure the machine with ubuntu operating system (or any debian based os) for web server.
2. Install the docker in the server machine by following docker standard installation guidelines followed by verifying the versions.
    Below are the reference links and commands to verify.
    > [Docker Installation](https://docs.docker.com/engine/install/ubuntu/#installation-methods)
    ```sh
    docker buildx version
    docker version
    docker compose version
    ```
3. Setup a machine for the database server (same as web server or separate machine). If it is different from web server then open connection for web server to communicate
    > [Mongo Installation](https://www.mongodb.com/docs/v7.0/tutorial/install-mongodb-on-ubuntu/)
4. Verifying the mongo database server by executing following command
    ```sh
    sudo systemctl status mongod
    ```
5. Install the mongo shell on the mongo database server
    > [Mongosh Installation](https://www.mongodb.com/docs/mongodb-shell/install/#procedure)
6. Verify the mongo shell with the following command to get a response of the installed version
    ```sh
    mongosh --version
    ```
#### Database server
1. connect to the mongo database server using mongo shell or mongo compass.
    ```sh
    mongosh
    ```
2. create a database with name `iwpms` using mongo shell
    ```js
    use iwpms
    ```
3. seed the database with the temp admin user for the iwpms application via the mongosh using following commands
    ```js
    use('iwpms');

    // Create a temp admin user with below command, password for the user is Test123!
    db.getCollection('users').insertOne({
    _id: '0dcf8aa5-5a25-4553-a8b0-7cf2bfe9c35d',
    UserName: 'admin@dualroots.com',
    NormalizedUserName: 'ADMIN@DUALROOTS.COM',
    Email: 'admin@dualroots.com',
    NormalizedEmail: 'ADMIN@DUALROOTS.COM',
    EmailConfirmed: false,
    PasswordHash: 'AQAAAAIAAYagAAAAEJGw/om4qQOm8mEY9AQ7yAWZt80ApsOwYWY9st+OvksxJsbZxzguekG58D/6Iuq6IQ==',
    SecurityStamp: 'KIUFCGUPXKOVDKATURC7IWEJBYIYWGGI',
    ConcurrencyStamp: '429fffcc-09a2-46c2-b320-86965c475462',
    PhoneNumber: null,
    PhoneNumberConfirmed: false,
    TwoFactorEnabled: false,
    LockoutEnd: null,
    LockoutEnabled: true,
    AccessFailedCount: 0,
    Version: 1,
    CreatedOn: ISODate('2024-10-20T17:22:29.883Z'),
    Claims: [
        {
        Type: 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name',
        Value: 'Admin',
        Issuer: null
        },
        {
        Type: 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress',
        Value: 'admin@dualroots.com',
        Issuer: null
        }
    ],
    Roles: [ 'Admin' ],
    Logins: [],
    Tokens: [],
    TenantId: null,
    IsActive: true,
    PreviousLoginTimestamp: null,
    LatestLoginTimestamp: null,
    LogoutTimestamp: null
    });

    // Create a participant for the user
    db.getCollection('participants').insertOne({
        _id: 'dc68b881-a9ae-4c80-8acc-5c5ee1ba1b07',
        Name: 'Admin',
        UserId: 'admin',
        ProfilePicture: '',
        Email: 'admin@dualroots.com',
        Description: '',
        MobileNo: { CountryCode: '+966', Number: '9999999999' },
        Address: '',
        ContractorId: '',
        SupervisorId: '',
        CompanyId: '',
        InternalDepartmentId: '',
        Type: 'Admin',
        Attachments: null,
        DisciplineId: '',
        CreatedBy: 'system',
        CreatedAt: ISODate('2024-11-17T17:34:16.435Z'),
        UpdatedBy: 'system',
        UpdatedAt: ISODate('2024-11-17T17:34:16.435Z'),
        LoginEnabled: true,
        IsActive: true
    });
    ```
4. Upon succesful login from the iwpms web application followed by creating another admin user, drop this temp admin user from the database via mongosh
    ```js
    use('iwpms');

    db.getCollection('users').deleteOne({'NormalizedEmail': 'ADMIN@DUALROOTS.COM'});

    db.getCollection('participants').deleteOne('Email': 'admin@dualroots.com');
    ```
#### Web server
1. create a directory in the server for the repositories eg. iwpms
    ```sh
    mkdir ~/iwpms # relative to current user directory eg. /home/<user>/iwpms
    ```
2. download the following artefacts from the WPQRCS organization of Dualroots AZDevops account
    ```sh
    cd ~/iwpms
    ```
    - client and server docker images tar files (Ensure names as iwpms_client.tar, iwpms_server.tar)
    - files folder (contains appsettings and nginx.conf)
    - load_images.sh, start.sh, and deploy.sh scripts
    - app.prod.yml deployment docker compose file
    ```sh
    chmod +x *.sh # to change the mode of the scripts as executable
    ```
3. update an appsettings file in the path `files/appsettings.json`
    ```sh
    cd ~/iwpms/files/
    ```
    #### Appsettings - Updates to each settings section of appsettings.json
    - #### Mongo
        - update the mongo settings section with correct connection string including user name, password, server address and port (default port is 27017)
        ```json
        "Mongo": {
            "ConnectionString": "mongodb://<server-address>:<port>",
            "DatabaseName": "iwpms"
        }
        ```
    - #### IdentitySettings
        - update the secret attribute of identity settings section with the secure and long key (of at-least 32 characters)
        - Expiration for the logged in user access token is 30 days
        ```json
        "IdentitySettings": {
            "Issuer": "http://<iwpms-web-server-address>:5000",
            "Audience": "iwpms",
            "Secret": "superSecretKey_KeepItVerySafe@3456789012",
            "ExpirationInHours": 760
        }
        ```
    - #### Smtp Settings
        - update the smpt settings with the iwpms office 365 email notification sender user credentials.
        - here user name and sender email can be the same and password will be the app password that got generated from office 365 admin center
        ```json
        "SmtpSettings": {
            "Server": "smtp.office365.com",
            "Port": 587,
            "SenderName": "IWPMS Dual Roots",
            "SenderEmail": "noreply@dualroots.com",
            "Username": "noreply@dualroots.com",
            "Password": "uhyybhvdxelahqty",
            "UseSSL": true,
            "RetryCount": 1
        }
        ```
    - #### Hangfire Settings
        - update the hangfire settings section connection string with the correct mongodb connection string.
        - update the hangfire dashboard username and password with the secure and secret credentials
        ```json
        "Hangfire": {
            "EnableServer": true,
            "ConnectionString": "mongodb://<server-address>:<port>",
            "Dashboard": {
                "Path": "/hangfire",
                "Username": "admin",
                "Password": "admin"
            },
            "Queues": [ "default", "notifications" ]
        }
        ```
    - #### Application Settings
        - update the application settings base address with the iwpms web application url (which got created for the application)
        - update the allowed origins with all the possible deployment addresses eg. iwpms
        ```json
        "ApplicationSettings": {
            "BaseUrl": "https://iwpms",
            "AllowedOrigins": [
                "iwpms"
            ]
        }
        ```
6. generate the valid https certificates for the server address
    - using openssl tools or other third party options by following standard guidelines
    - copy the iwpms.cert, iwpms.key into `iwpms/files/cert` directory
    - use the same name as defined above to not cause any confusion else update the deployment scripts with the correct names
    - update the nginx.conf of `iwpms` to set the server cert and private key
    ```js
    {
        server {
            listen 443 ssl;
            ssl_certificate /path/to/iwpms.crt;
            ssl_certificate_key /path/to/iwpms.key;
            # ... other configurations
        }

        server {
            listen 5001 ssl;
            ssl_certificate /path/to/iwpms.crt;
            ssl_certificate_key /path/to/iwpms.key;
            # ... other configurations
        }
    }
    ```
5. deploy the built images using the following docker compose commands
    #### docker compoe file
        - update the timezone with the location of the iwpms server eg. Asia/Calcutta if it is hosted for indian clients
        ```sh
        ./deploy.sh
        ```
        - Above script loads the docker images for both client and server (via load_images.sh) followed by starting the servers through docker compose (via start.sh)
6. clean up the deployed instances using the following command
    ```sh
    docker compose -f app.prod.yml down
    ```
