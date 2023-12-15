ALTER SEQUENCE user_access.user_user_id_seq restart with 10000;

-- ******************************************
--
-- This script will add a test user to EHM system with:
-- 1) All the roles.
-- 2) All the work groups.
-- 3) Supervisor of Group: GAL2 Ind. - Global.
--
-- You just need to update the user details highlighted in the "TODO" block.
--
-- ******************************************
DO $$
-- ******************************************
--
-- TODO: Update the details of the user you want to add here
--
-- ******************************************
    DECLARE u_id BIGINT; -- The next ID of the user table will be used.
        DECLARE u_email VARCHAR(200) := 'ehm@kingland.com';
        DECLARE account_name VARCHAR(200) := 'ehm';
        DECLARE first_name VARCHAR(200) := 'EHM';
        DECLARE last_name VARCHAR(200) := 'EHM';
        DECLARE domain VARCHAR(200) := 'US';
        DECLARE country VARCHAR(200) := 'US';
        DECLARE office VARCHAR(200) := '';
    BEGIN
        ------------------------------------
        -- 0. Validation
        ------------------------------------
        SELECT nextval('user_access.user_user_id_seq') INTO u_id;
        IF EXISTS (SELECT * FROM user_access."user" WHERE user_id=u_id) THEN RAISE 'The user ID already exists.'; END IF;
        IF EXISTS (SELECT * FROM user_access."user" WHERE username=u_email) THEN RAISE 'The user email already exists.'; END IF;

        ------------------------------------
        -- 1. Insert user_transaction
        ------------------------------------
        IF NOT EXISTS(SELECT * FROM user_access.user_transaction WHERE transaction_id = 'local_test_transaction') THEN
            INSERT INTO user_access.user_transaction (
                transaction_id,
                transaction_user_id,
                transaction_date,
                source_id, source_description, source_type_code, user_name
            )
            VALUES(
                      'local_test_transaction',
                      1,
                      CURRENT_TIMESTAMP::TIMESTAMP WITHOUT TIME ZONE,
                      NULL::bigint, '', NULL::bigint, ''
                  );
        END IF;

        ------------------------------------
        -- 2. Insert User
        ------------------------------------
        INSERT INTO user_access."user" (
            user_id,
            username,
            password,
            email,
            first_name,
            last_name,
            attributes,
            transaction_id,
            challenge_one, answer_one, is_active
        )
        SELECT
            u_id,
            u_email AS username,
            '$2a$05$zita.Gzl8NLApOtKyLSBpexBZziZ7JiiD1eqosK.up9uYMj013m9K' AS password,
            u_email,
            first_name,
            last_name,
            (
                                                                        '{' ||
                                                                        '"lastDateSynchronized":' || TO_JSON((EXTRACT(EPOCH FROM CURRENT_TIMESTAMP::TIMESTAMP WITHOUT TIME ZONE)* 1000)::BIGINT ) ||
                                                                        ',"guid":' || TO_JSON(LOWER('00000000-0000-0000-0000-000000000' || (u_id)::VARCHAR)) ||
                                                                        ',"country":' || TO_JSON(country) ||
                                                                        ',"domain":' || TO_JSON(domain) ||
                                                                        ',"accountName":' || TO_JSON(account_name) ||
                                                                        ',"displayName":' || TO_JSON(first_name || ' ' || last_name) ||
                                                                        CASE
                                                                            WHEN COALESCE(office, '')<>'' THEN ',"office":' || TO_JSON(office)
                                                                            ELSE ''
                                                                            END ||
                                                                        '}'
                )::JSON AS attributes,
            'local_test_transaction' AS transaction_id,
            '' AS challenge_one, '' AS answer_one, true AS is_active
        ;

        INSERT INTO user_access.user_detail(user_id, effective_date, transaction_id, is_active)
        SELECT
            u_id,
            CURRENT_TIMESTAMP::TIMESTAMP WITHOUT TIME ZONE AS effective_date,
            'local_test_transaction' AS transaction_id,
            true
        ;

        INSERT INTO user_access.user_transaction_ext(transaction_id, user_id)
        SELECT
            'local_test_transaction' AS transaction_id,
            u_id
        ;

        ------------------------------------
        -- 3. Assign User Roles
        ------------------------------------
        INSERT INTO user_access.user_role_xref(role_id, user_id, is_active, transaction_id, location_type_code, object_id)
            -- System Administrator
        SELECT DISTINCT role_id, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        FROM user_access.role
        WHERE is_active = true;

        ------------------------------------
        -- 4. Assign User Groups
        ------------------------------------
        -- Add user to Groups
        INSERT INTO user_access."user_group_xref"(group_id, user_id, transaction_id, is_active)
        SELECT
            t1.group_id,
            u_id,
            'local_test_transaction',
            TRUE
        FROM
            user_access."group" t1
                LEFT JOIN user_access.user_group_xref t2 ON t1.group_id = t2.group_id AND t2.user_id = u_id
        WHERE t2.group_id IS NULL;

        -- Set the current user as the supervisor of the work group
        INSERT INTO user_access.user_role_xref(role_id, user_id, is_active, transaction_id, location_type_code, object_id)
            -- Supervisor of Group: GAL2 Ind. - Global
        SELECT DISTINCT 1, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, 1032;
    END $$;


-- ******************************************
--
-- This script will add a test user to EHM system with:
-- 1) The following roles: System Administrator, all Entity Reviewer roles, and Eligible to be RP.
-- 2) All the work groups.
-- 3) Supervisor of Group: GAL2 Ind. - Global.
--
-- You just need to update the user details highlighted in the "TODO" block.
--
-- ******************************************
DO $$
-- ******************************************
--
-- TODO: Update the details of the user you want to add here
--
-- ******************************************
    DECLARE u_id BIGINT; -- The next ID of the user table will be used.
    DECLARE u_email VARCHAR(200) := 'ehm1@kingland.com';
    DECLARE account_name VARCHAR(200) := 'ehm1';
    DECLARE first_name VARCHAR(200) := 'EHM1';
    DECLARE last_name VARCHAR(200) := 'EHM1';
    DECLARE domain VARCHAR(200) := 'US';
    DECLARE country VARCHAR(200) := 'US';
    DECLARE office VARCHAR(200) := '';
    BEGIN
        ------------------------------------
        -- 0. Validation
        ------------------------------------
        SELECT nextval('user_access.user_user_id_seq') INTO u_id;
        IF EXISTS (SELECT * FROM user_access."user" WHERE user_id=u_id) THEN RAISE 'The user ID already exists.'; END IF;
        IF EXISTS (SELECT * FROM user_access."user" WHERE username=u_email) THEN RAISE 'The user email already exists.'; END IF;

        ------------------------------------
        -- 1. Insert user_transaction
        ------------------------------------
        IF NOT EXISTS(SELECT * FROM user_access.user_transaction WHERE transaction_id = 'local_test_transaction') THEN
            INSERT INTO user_access.user_transaction (
                transaction_id,
                transaction_user_id,
                transaction_date,
                source_id, source_description, source_type_code, user_name
            )
            VALUES(
                'local_test_transaction',
                1,
                CURRENT_TIMESTAMP::TIMESTAMP WITHOUT TIME ZONE,
                NULL::bigint, '', NULL::bigint, ''
            );
        END IF;

        ------------------------------------
        -- 2. Insert User
        ------------------------------------
        INSERT INTO user_access."user" (
            user_id,
            username,
            password,
            email,
            first_name,
            last_name,
            attributes,
            transaction_id,
            challenge_one, answer_one, is_active
        )
        SELECT
            u_id,
            u_email AS username,
            '$2a$05$zita.Gzl8NLApOtKyLSBpexBZziZ7JiiD1eqosK.up9uYMj013m9K' AS password,
            u_email,
            first_name,
            last_name,
            (
                '{' ||
                '"lastDateSynchronized":' || TO_JSON((EXTRACT(EPOCH FROM CURRENT_TIMESTAMP::TIMESTAMP WITHOUT TIME ZONE)* 1000)::BIGINT ) ||
                ',"guid":' || TO_JSON(LOWER('00000000-0000-0000-0000-000000000' || (u_id)::VARCHAR)) ||
                ',"country":' || TO_JSON(country) ||
                ',"domain":' || TO_JSON(domain) ||
                ',"accountName":' || TO_JSON(account_name) ||
                ',"displayName":' || TO_JSON(first_name || ' ' || last_name) ||
                CASE
                    WHEN COALESCE(office, '')<>'' THEN ',"office":' || TO_JSON(office)
                    ELSE ''
                    END ||
                '}'
            )::JSON AS attributes,
            'local_test_transaction' AS transaction_id,
            '' AS challenge_one, '' AS answer_one, true AS is_active
        ;

        INSERT INTO user_access.user_detail(user_id, effective_date, transaction_id, is_active)
        SELECT
            u_id,
            CURRENT_TIMESTAMP::TIMESTAMP WITHOUT TIME ZONE AS effective_date,
            'local_test_transaction' AS transaction_id,
            true
        ;

        INSERT INTO user_access.user_transaction_ext(transaction_id, user_id)
        SELECT
            'local_test_transaction' AS transaction_id,
            u_id
        ;

        ------------------------------------
        -- 3. Assign User Roles
        ------------------------------------
        INSERT INTO user_access.user_role_xref(role_id, user_id, is_active, transaction_id, location_type_code, object_id)
            -- System Administrator
        SELECT DISTINCT 5, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- Eligible to be RP
        SELECT DISTINCT 114, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- Global Level 1 Entity Reviewer
        SELECT DISTINCT 115, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- Global Level 2 Entity Reviewer
        SELECT DISTINCT 116, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- MemberFirm Level 1 Entity Reviewer
        SELECT DISTINCT 117, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- MemberFirm Level 2 Entity Reviewer
        SELECT DISTINCT 118, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        ;

        ------------------------------------
        -- 4. Assign User Groups
        ------------------------------------
        -- Add user to Groups
        INSERT INTO user_access."user_group_xref"(group_id, user_id, transaction_id, is_active)
        SELECT
            t1.group_id,
            u_id,
            'local_test_transaction',
            TRUE
        FROM
            user_access."group" t1
                LEFT JOIN user_access.user_group_xref t2 ON t1.group_id = t2.group_id AND t2.user_id = u_id
        WHERE t2.group_id IS NULL;

        -- Set the current user as the supervisor of the work group
        INSERT INTO user_access.user_role_xref(role_id, user_id, is_active, transaction_id, location_type_code, object_id)
            -- Supervisor of Group: GAL2 Ind. - Global
        SELECT DISTINCT 1, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, 1032;
    END $$;


-- ******************************************
--
-- This script will add a test user to EHM system with:
-- 1) The following roles: System Administrator, all Entity Reviewer roles, and Eligible to be RP.
-- 2) All the work groups.
-- 3) Supervisor of Group: GAL2 Ind. - Global.
--
-- You just need to update the user details highlighted in the "TODO" block.
--
-- ******************************************
DO $$
-- ******************************************
--
-- TODO: Update the details of the user you want to add here
--
-- ******************************************
    DECLARE u_id BIGINT; -- The next ID of the user table will be used.
        DECLARE u_email VARCHAR(200) := 'ehm2@kingland.com';
        DECLARE account_name VARCHAR(200) := 'ehm2';
        DECLARE first_name VARCHAR(200) := 'EHM2';
        DECLARE last_name VARCHAR(200) := 'EHM2';
        DECLARE domain VARCHAR(200) := 'US';
        DECLARE country VARCHAR(200) := 'US';
        DECLARE office VARCHAR(200) := '';
    BEGIN
        ------------------------------------
        -- 0. Validation
        ------------------------------------
        SELECT nextval('user_access.user_user_id_seq') INTO u_id;
        IF EXISTS (SELECT * FROM user_access."user" WHERE user_id=u_id) THEN RAISE 'The user ID already exists.'; END IF;
        IF EXISTS (SELECT * FROM user_access."user" WHERE username=u_email) THEN RAISE 'The user email already exists.'; END IF;

        ------------------------------------
        -- 1. Insert user_transaction
        ------------------------------------
        IF NOT EXISTS(SELECT * FROM user_access.user_transaction WHERE transaction_id = 'local_test_transaction') THEN
            INSERT INTO user_access.user_transaction (
                transaction_id,
                transaction_user_id,
                transaction_date,
                source_id, source_description, source_type_code, user_name
            )
            VALUES(
                      'local_test_transaction',
                      1,
                      CURRENT_TIMESTAMP::TIMESTAMP WITHOUT TIME ZONE,
                      NULL::bigint, '', NULL::bigint, ''
                  );
        END IF;

        ------------------------------------
        -- 2. Insert User
        ------------------------------------
        INSERT INTO user_access."user" (
            user_id,
            username,
            password,
            email,
            first_name,
            last_name,
            attributes,
            transaction_id,
            challenge_one, answer_one, is_active
        )
        SELECT
            u_id,
            u_email AS username,
            '5266a84bf4aa38f1e6673f51bd596077028148c8' AS password,
            u_email,
            first_name,
            last_name,
            (
                                                                        '{' ||
                                                                        '"lastDateSynchronized":' || TO_JSON((EXTRACT(EPOCH FROM CURRENT_TIMESTAMP::TIMESTAMP WITHOUT TIME ZONE)* 1000)::BIGINT ) ||
                                                                        ',"guid":' || TO_JSON(LOWER('00000000-0000-0000-0000-000000000' || (u_id)::VARCHAR)) ||
                                                                        ',"country":' || TO_JSON(country) ||
                                                                        ',"domain":' || TO_JSON(domain) ||
                                                                        ',"accountName":' || TO_JSON(account_name) ||
                                                                        ',"displayName":' || TO_JSON(first_name || ' ' || last_name) ||
                                                                        CASE
                                                                            WHEN COALESCE(office, '')<>'' THEN ',"office":' || TO_JSON(office)
                                                                            ELSE ''
                                                                            END ||
                                                                        '}'
                )::JSON AS attributes,
            'local_test_transaction' AS transaction_id,
            '' AS challenge_one, '' AS answer_one, true AS is_active
        ;

        INSERT INTO user_access.user_detail(user_id, effective_date, transaction_id, is_active)
        SELECT
            u_id,
            CURRENT_TIMESTAMP::TIMESTAMP WITHOUT TIME ZONE AS effective_date,
            'local_test_transaction' AS transaction_id,
            true
        ;

        INSERT INTO user_access.user_transaction_ext(transaction_id, user_id)
        SELECT
            'local_test_transaction' AS transaction_id,
            u_id
        ;

        ------------------------------------
        -- 3. Assign User Roles
        ------------------------------------
        INSERT INTO user_access.user_role_xref(role_id, user_id, is_active, transaction_id, location_type_code, object_id)
            -- System Administrator
        SELECT DISTINCT 5, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- Eligible to be RP
        SELECT DISTINCT 114, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- Global Level 1 Entity Reviewer
        SELECT DISTINCT 115, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- Global Level 2 Entity Reviewer
        SELECT DISTINCT 116, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- MemberFirm Level 1 Entity Reviewer
        SELECT DISTINCT 117, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- MemberFirm Level 2 Entity Reviewer
        SELECT DISTINCT 118, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        ;

        ------------------------------------
        -- 4. Assign User Groups
        ------------------------------------
        -- Add user to Groups
        INSERT INTO user_access."user_group_xref"(group_id, user_id, transaction_id, is_active)
        SELECT
            t1.group_id,
            u_id,
            'local_test_transaction',
            TRUE
        FROM
            user_access."group" t1
                LEFT JOIN user_access.user_group_xref t2 ON t1.group_id = t2.group_id AND t2.user_id = u_id
        WHERE t2.group_id IS NULL;

        -- Set the current user as the supervisor of the work group
        INSERT INTO user_access.user_role_xref(role_id, user_id, is_active, transaction_id, location_type_code, object_id)
            -- Supervisor of Group: GAL2 Ind. - Global
        SELECT DISTINCT 1, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, 1032;
    END $$;



-- ******************************************
--
-- This script will add a test user to EHM system with:
-- 1) The following roles: System Administrator, all Entity Reviewer roles, and Eligible to be RP.
-- 2) All the work groups.
-- 3) Supervisor of Group: GAL2 Ind. - Global.
--
-- You just need to update the user details highlighted in the "TODO" block.
--
-- ******************************************
DO $$
-- ******************************************
--
-- TODO: Update the details of the user you want to add here
--
-- ******************************************
    DECLARE u_id BIGINT; -- The next ID of the user table will be used.
        DECLARE u_email VARCHAR(200) := 'ehm3@kingland.com';
        DECLARE account_name VARCHAR(200) := 'ehm3';
        DECLARE first_name VARCHAR(200) := 'EHM3';
        DECLARE last_name VARCHAR(200) := 'EHM3';
        DECLARE domain VARCHAR(200) := 'US';
        DECLARE country VARCHAR(200) := 'US';
        DECLARE office VARCHAR(200) := '';
    BEGIN
        ------------------------------------
        -- 0. Validation
        ------------------------------------
        SELECT nextval('user_access.user_user_id_seq') INTO u_id;
        IF EXISTS (SELECT * FROM user_access."user" WHERE user_id=u_id) THEN RAISE 'The user ID already exists.'; END IF;
        IF EXISTS (SELECT * FROM user_access."user" WHERE username=u_email) THEN RAISE 'The user email already exists.'; END IF;

        ------------------------------------
        -- 1. Insert user_transaction
        ------------------------------------
        IF NOT EXISTS(SELECT * FROM user_access.user_transaction WHERE transaction_id = 'local_test_transaction') THEN
            INSERT INTO user_access.user_transaction (
                transaction_id,
                transaction_user_id,
                transaction_date,
                source_id, source_description, source_type_code, user_name
            )
            VALUES(
                      'local_test_transaction',
                      1,
                      CURRENT_TIMESTAMP::TIMESTAMP WITHOUT TIME ZONE,
                      NULL::bigint, '', NULL::bigint, ''
                  );
        END IF;

        ------------------------------------
        -- 2. Insert User
        ------------------------------------
        INSERT INTO user_access."user" (
            user_id,
            username,
            password,
            email,
            first_name,
            last_name,
            attributes,
            transaction_id,
            challenge_one, answer_one, is_active
        )
        SELECT
            u_id,
            u_email AS username,
            '5266a84bf4aa38f1e6673f51bd596077028148c8' AS password,
            u_email,
            first_name,
            last_name,
            (
                                                                        '{' ||
                                                                        '"lastDateSynchronized":' || TO_JSON((EXTRACT(EPOCH FROM CURRENT_TIMESTAMP::TIMESTAMP WITHOUT TIME ZONE)* 1000)::BIGINT ) ||
                                                                        ',"guid":' || TO_JSON(LOWER('00000000-0000-0000-0000-000000000' || (u_id)::VARCHAR)) ||
                                                                        ',"country":' || TO_JSON(country) ||
                                                                        ',"domain":' || TO_JSON(domain) ||
                                                                        ',"accountName":' || TO_JSON(account_name) ||
                                                                        ',"displayName":' || TO_JSON(first_name || ' ' || last_name) ||
                                                                        CASE
                                                                            WHEN COALESCE(office, '')<>'' THEN ',"office":' || TO_JSON(office)
                                                                            ELSE ''
                                                                            END ||
                                                                        '}'
                )::JSON AS attributes,
            'local_test_transaction' AS transaction_id,
            '' AS challenge_one, '' AS answer_one, true AS is_active
        ;

        INSERT INTO user_access.user_detail(user_id, effective_date, transaction_id, is_active)
        SELECT
            u_id,
            CURRENT_TIMESTAMP::TIMESTAMP WITHOUT TIME ZONE AS effective_date,
            'local_test_transaction' AS transaction_id,
            true
        ;

        INSERT INTO user_access.user_transaction_ext(transaction_id, user_id)
        SELECT
            'local_test_transaction' AS transaction_id,
            u_id
        ;

        ------------------------------------
        -- 3. Assign User Roles
        ------------------------------------
        INSERT INTO user_access.user_role_xref(role_id, user_id, is_active, transaction_id, location_type_code, object_id)
            -- System Administrator
        SELECT DISTINCT 5, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- Eligible to be RP
        SELECT DISTINCT 114, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- Global Level 1 Entity Reviewer
        SELECT DISTINCT 115, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- Global Level 2 Entity Reviewer
        SELECT DISTINCT 116, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- MemberFirm Level 1 Entity Reviewer
        SELECT DISTINCT 117, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        UNION
        -- MemberFirm Level 2 Entity Reviewer
        SELECT DISTINCT 118, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, NULL::BIGINT
        ;

        ------------------------------------
        -- 4. Assign User Groups
        ------------------------------------
        -- Add user to Groups
        INSERT INTO user_access."user_group_xref"(group_id, user_id, transaction_id, is_active)
        SELECT
            t1.group_id,
            u_id,
            'local_test_transaction',
            TRUE
        FROM
            user_access."group" t1
                LEFT JOIN user_access.user_group_xref t2 ON t1.group_id = t2.group_id AND t2.user_id = u_id
        WHERE t2.group_id IS NULL;

        -- Set the current user as the supervisor of the work group
        INSERT INTO user_access.user_role_xref(role_id, user_id, is_active, transaction_id, location_type_code, object_id)
            -- Supervisor of Group: GAL2 Ind. - Global
        SELECT DISTINCT 1, u_id, TRUE, 'local_test_transaction', NULL::BIGINT, 1032;
    END $$;