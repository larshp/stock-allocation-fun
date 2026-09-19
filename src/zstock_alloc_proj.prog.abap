REPORT zstock_alloc_proj.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.
PARAMETERS p_days TYPE i DEFAULT 7.
PARAMETERS p_count TYPE i DEFAULT 8.

START-OF-SELECTION.

  " which locations count and whether the plan counts are the plant's own
  " settings, the same ones a run would use
  TRY.
      DATA(lt_line) = zcl_alloc_projection=>create_for_plant( p_werks )->run(
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
