REPORT zstock_alloc_proj.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.
PARAMETERS p_days TYPE i DEFAULT 7.
PARAMETERS p_count TYPE i DEFAULT 8.

START-OF-SELECTION.

  " which locations count and whether the plan counts are the plant's own
  " settings, the same ones a run would use
  DATA(lo_config) = CAST zif_alloc_config( NEW zcl_alloc_config( ) ).
  DATA(ls_settings) = lo_config->for_plant( p_werks ).

  TRY.
      DATA(lt_line) = zcl_alloc_projection=>create_default(
        iv_lgort        = ls_settings-lgort
        iv_planned      = ls_settings-planned
        iv_horizon_days = ls_settings-horizon_days
        iv_ship_days    = ls_settings-ship_days )->run(
          iv_matnr   = p_matnr
          iv_werks   = p_werks
          iv_days    = p_days
          iv_buckets = p_count ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
