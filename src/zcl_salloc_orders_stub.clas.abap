CLASS zcl_salloc_orders_stub DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salloc_orders.
    METHODS constructor
      IMPORTING
        it_demands TYPE zif_salloc_types=>tt_demands
        iv_fail_on_save TYPE abap_bool DEFAULT abap_false.
    METHODS get_saved
      RETURNING VALUE(rt_demands) TYPE zif_salloc_types=>tt_demands.
  PRIVATE SECTION.
    DATA mt_demands TYPE zif_salloc_types=>tt_demands.
    DATA mt_saved TYPE zif_salloc_types=>tt_demands.
    DATA mv_fail_on_save TYPE abap_bool.
ENDCLASS.

CLASS zcl_salloc_orders_stub IMPLEMENTATION.
  METHOD constructor.
    mt_demands = it_demands.
    mv_fail_on_save = iv_fail_on_save.
  ENDMETHOD.

  METHOD zif_salloc_orders~get_open_demands.
    rt_demands = mt_demands.
  ENDMETHOD.

  METHOD zif_salloc_orders~save_allocations.
    IF mv_fail_on_save = abap_true.
      RAISE EXCEPTION TYPE zcx_salloc_integration
        EXPORTING
          iv_operation = `SAVE_ALLOCATIONS`
          iv_reason = `Configured test failure`.
    ENDIF.
    mt_saved = it_demands.
  ENDMETHOD.

  METHOD zif_salloc_orders~release_allocation.
    READ TABLE mt_saved ASSIGNING FIELD-SYMBOL(<saved>)
      WITH KEY order_id = iv_order_id.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_salloc_integration
        EXPORTING
          iv_operation = `RELEASE_ALLOCATION`
          iv_reason = `Release exceeds order allocation`.
    ELSEIF <saved>-allocated < iv_quantity.
      RAISE EXCEPTION TYPE zcx_salloc_integration
        EXPORTING
          iv_operation = `RELEASE_ALLOCATION`
          iv_reason = `Release exceeds order allocation`.
    ENDIF.
    <saved>-allocated = <saved>-allocated - iv_quantity.
    IF iv_reconcile = abap_true.
      IF <saved>-allocated > iv_supported.
        RAISE EXCEPTION TYPE zcx_salloc_integration
          EXPORTING
            iv_operation = `RELEASE_ALLOCATION`
            iv_reason = `Reconciled allocation exceeds supported demand`.
      ENDIF.
      <saved>-requested = iv_supported.
      <saved>-shortage = iv_supported - <saved>-allocated.
    ELSE.
      <saved>-shortage = <saved>-shortage + iv_quantity.
    ENDIF.
  ENDMETHOD.

  METHOD get_saved.
    rt_demands = mt_saved.
  ENDMETHOD.
ENDCLASS.
