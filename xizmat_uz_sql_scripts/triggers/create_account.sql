CREATE OR REPLACE FUNCTION public.create_account()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
  DECLARE
  temp_account_id bigint;
  account_number varchar;
  BEGIN
    INSERT INTO public.accounts (user_id) VALUES(new.id) RETURNING id INTO temp_account_id;
    UPDATE public.accounts SET account_number = concat('X10', temp_account_id) where id = temp_account_id;
    INSERT INTO public.balances (account_id, amount) VALUES(temp_account_id, 0.0);
    RETURN NEW;
  END;
$function$;
DROP TRIGGER IF EXISTS "create_user_account" ON "public"."users";
CREATE TRIGGER "create_user_account" AFTER
INSERT ON "public"."users" FOR EACH ROW
EXECUTE PROCEDURE "public".create_account();
