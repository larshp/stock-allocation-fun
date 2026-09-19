REPORT zstock_alloc_mix.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_dispo TYPE marc-dispo.
PARAMETERS p_kunnr TYPE vbak-kunnr.
PARAMETERS p_mail TYPE ad_smtpadr.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_reason_mix=>create_default( )->run(
        iv_werks = p_werks
        iv_dispo = p_dispo
        iv_kunnr = p_kunnr ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.

  " the page a manager asks for once a month is the page nobody remembers to
  " run. Scheduled with an address, it arrives.
  IF p_mail IS NOT INITIAL.
    TRY.
        CAST zif_mail_sender( NEW zcl_mail_sender( ) )->send(
          iv_to      = |{ p_mail }|
          iv_subject = |Stock allocation: where the shortfall goes in { p_werks }|
          it_line    = lt_line ).
      CATCH zcx_allocation INTO DATA(lx_mail).
        WRITE / lx_mail->get_text( ).
    ENDTRY.
  ENDIF.
