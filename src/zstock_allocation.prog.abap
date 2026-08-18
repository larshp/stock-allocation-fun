REPORT zstock_allocation.

PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.
PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_fair AS CHECKBOX.

START-OF-SELECTION.

  DATA lo_strategy TYPE REF TO zif_allocation_strategy.

  IF p_fair = abap_true.
    lo_strategy = NEW zcl_alloc_strategy_fairshare( ).
  ENDIF.

  DATA(lo_report) = NEW zcl_allocation_report(
    zcl_allocation_service=>create_default( lo_strategy ) ).

  DATA(lt_line) = lo_report->run(
    iv_matnr = p_matnr
    iv_werks = p_werks ).

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
