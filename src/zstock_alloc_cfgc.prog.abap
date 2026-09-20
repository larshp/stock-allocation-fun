REPORT zstock_alloc_cfgc.

PARAMETERS p_werks TYPE mard-werks.
PARAMETERS p_all AS CHECKBOX.

START-OF-SELECTION.

  DATA lt_line TYPE zcl_alloc_cfg_check=>ty_line_tab.

  " a plant or all of them: after a transport the question is whether any of
  " it landed wrongly anywhere, and one plant at a time is how somebody misses
  " the one they were not thinking about
  IF p_all = abap_false AND p_werks IS INITIAL.
    WRITE / 'Name a plant, or tick every plant'.
    RETURN.
  ENDIF.

  TRY.
      IF p_all = abap_true.
        lt_line = zcl_alloc_cfg_check=>create_default( )->run_everywhere( ).
      ELSE.
        lt_line = zcl_alloc_cfg_check=>create_default( )->run( p_werks ).
      ENDIF.
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
