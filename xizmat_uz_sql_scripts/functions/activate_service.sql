CREATE OR REPLACE FUNCTION public.activate_service(temp_service_id bigint)
 RETURNS SETOF public.service_accounts
 LANGUAGE plpgsql
AS $function$
DECLARE
    hasura_session json;
    temp_account_id bigint;
    service_account_id bigint;
    old_balance money;
    service_price money;
BEGIN
    IF channel_name IS NULL THEN
        RAISE EXCEPTION 'Channel name can not be null ';
    END IF;
    hasura_session := current_setting('hasura.user', 't');
    SELECT id INTO temp_account_id FROM public where user_id = (hasura_session ->> 'x-hasura-user-id')::uuid;
    IF temp_account_id IS NULL THEN
        RAISE EXCEPTION 'None user';
    END IF;
    SELECT id, price INTO service_account_id, service_price from public.service_accounts where account_id = temp_account_id  and service_id = temp_service_id;
    
    IF service_account_id IS NULL THEN
        RAISE EXCEPTION 'No account service';
    END IF;
     SELECT amount INTO old_balance from public.balances where account_id = temp_account_id;
    if old_balance >= service_price 
    THEN
        UPDATE public.balances set amount = old_balance - service_price WHERE account_id = temp_account_id;
        UPDATE public.service_accounts set payment_status = 1 WHERE id = service_account_id;
    ELSE
        RAISE EXCEPTION 'No money';
    END IF;
   
    RETURN QUERY SELECT * from public.service_accounts where id = service_account_id;

END
$function$
