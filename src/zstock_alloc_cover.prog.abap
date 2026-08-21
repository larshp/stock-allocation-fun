REPORT zstock_alloc_cover.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_hours TYPE i DEFAULT 24.
PARAMETERS p_mail TYPE ad_smtpadr.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_coverage=>create_for_plant( p_werks )->run(
        iv_werks = p_werks
        iv_hours = p_hours ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.

  " the question this report answers -- did the night finish -- is one
  " somebody wants the answer to without having to ask
  IF p_mail IS NOT INITIAL.
    TRY.
        CAST zif_mail_sender( NEW zcl_mail_sender( ) )->send(
          iv_to      = |{ p_mail }|
          iv_subject = |Stock allocation: what { p_werks } did not get to|
          it_line    = lt_line ).
      CATCH zcx_allocation INTO DATA(lx_mail).
        WRITE / lx_mail->get_text( ).
    ENDTRY.
  ENDIF.
