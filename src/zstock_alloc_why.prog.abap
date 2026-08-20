REPORT zstock_alloc_why.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.

START-OF-SELECTION.

  " which locations count and whether the plan counts are decisions about the
  " plant, and the working shown has to be the working a run would do
  DATA(lo_config) = CAST zif_alloc_config( NEW zcl_alloc_config( ) ).
  DATA(ls_settings) = lo_config->for_plant( p_werks ).

  TRY.
      DATA(lt_line) = zcl_alloc_explain=>create_default(
        iv_lgort   = ls_settings-lgort
        iv_planned = ls_settings-planned )->run(
          iv_matnr = p_matnr
          iv_werks = p_werks ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
