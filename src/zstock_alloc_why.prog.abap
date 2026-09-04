REPORT zstock_alloc_why.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.

START-OF-SELECTION.

  " the working shown has to be the working done, so the plant's own rule and
  " its own limits are the ones the explanation uses
  TRY.
      DATA(lt_line) = zcl_alloc_explain=>create_for_plant( p_werks )->run(
        iv_matnr = p_matnr
        iv_werks = p_werks ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
