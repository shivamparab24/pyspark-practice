CREATE PROCEDURE dbo.sp_load_users
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.users (user_id, name, email)
        SELECT
            s.user_id,
            s.name,
            s.email
        FROM dbo.stg_users s
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.users u
            WHERE u.user_id = s.user_id
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
