REPORT zstock_alloc_short.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_until TYPE d.
PARAMETERS p_top TYPE i DEFAULT 0.
PARAMETERS p_dispo TYPE marc-dispo.
PARAMETERS p_kunnr TYPE vbak-kunnr.
PARAMETERS p_chron AS CHECKBOX.
PARAMETERS p_mail TYPE ad_smtpadr.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_shortage_list=>create_default( )->run(
        iv_werks = p_werks
        iv_until = p_until
        iv_top   = p_top
        iv_dispo = p_dispo
        iv_kunnr = p_kunnr
        iv_sort  = COND #( WHEN p_chron = abap_true
                           THEN zcl_alloc_shortage_list=>c_by_waiting ) ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.

  " a list a planner has to remember to run is a list that gets run on the
  " mornings somebody remembers. Scheduled with an address, it arrives.
  IF p_mail IS NOT INITIAL.
    TRY.
        CAST zif_mail_sender( NEW zcl_mail_sender( ) )->send(
          iv_to      = |{ p_mail }|
          iv_subject = |Stock allocation: what is short in { p_werks }|
          it_line    = lt_line ).
      CATCH zcx_allocation INTO DATA(lx_mail).
        WRITE / lx_mail->get_text( ).
    ENDTRY.
  ENDIF.
