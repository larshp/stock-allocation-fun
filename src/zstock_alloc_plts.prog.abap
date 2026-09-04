REPORT zstock_alloc_plts.

PARAMETERS p_mail TYPE ad_smtpadr.
PARAMETERS p_only AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.

  DATA lv_worth_sending TYPE abap_bool.

  DATA(lo_list) = zcl_alloc_plant_list=>create_default( ).

  DATA(lt_line) = lo_list->run( ).

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.

  IF p_mail IS INITIAL.
    RETURN.
  ENDIF.

  " a plant that is short of something or did not run is worth writing to
  " somebody about at seven in the morning; a page of noughts is not, and a
  " page of noughts that arrives every day is why nobody reads the one that
  " matters
  LOOP AT lo_list->stands( ) INTO DATA(ls_plant).
    IF ls_plant-short > 0 OR ls_plant-ran_today = abap_false.
      lv_worth_sending = abap_true.
    ENDIF.
  ENDLOOP.

  IF p_only = abap_true AND lv_worth_sending = abap_false.
    RETURN.
  ENDIF.

  TRY.
      CAST zif_mail_sender( NEW zcl_mail_sender( ) )->send(
        iv_to      = |{ p_mail }|
        iv_subject = `Stock allocation: how the plants stand`
        it_line    = lt_line ).
    CATCH zcx_allocation INTO DATA(lx_mail).
      WRITE / lx_mail->get_text( ).
  ENDTRY.
