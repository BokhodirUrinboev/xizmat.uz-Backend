CREATE OR REPLACE FUNCTION public.refil_balance(payment_type int, refil_amount money)
 RETURNS SETOF public.payments
 LANGUAGE plpgsql
AS $function$
DECLARE
    hasura_session json;
    temp_account_id bigint;
    temp_payment_id bigint;
    old_balance money;
BEGIN
    IF channel_name IS NULL THEN
        RAISE EXCEPTION 'Channel name can not be null ';
    END IF;
    hasura_session := current_setting('hasura.user', 't');
    SELECT id INTO temp_account_id FROM public where user_id = (hasura_session ->> 'x-hasura-user-id')::uuid;
    IF temp_account_id IS NULL THEN
        RAISE EXCEPTION 'None user';
    END IF;
    INSERT INTO public.payments (account_id, type, amount) VALUES (temp_account_id, payment_type, refil_amount) RETURNING id temp_payment_id;
    SELECT amount INTO old_balance from public.balances where account_id = temp_account_id;
    UPDATE public.balances set amount = (old_balance + refil_amount) where account_id = temp_account_id;
    RETURN QUERY SELECT * from public.payments where id = temp_payment_id;

END
$function$
