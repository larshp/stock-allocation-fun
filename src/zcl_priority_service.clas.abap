CLASS zcl_priority_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_authorization TYPE REF TO zif_priority_authorization
        io_lock          TYPE REF TO zif_allocation_lock
        io_sink          TYPE REF TO zif_priority_sink
        io_log           TYPE REF TO zif_priority_log.
    METHODS set_priority
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
        iv_sales_order      TYPE zif_stock_allocation=>ty_sales_order
        iv_sales_item       TYPE zif_stock_allocation=>ty_sales_item
        iv_priority         TYPE zif_stock_allocation=>ty_priority
      RAISING
        zcx_stock_allocation.
    METHODS remove_priority
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
        iv_sales_order      TYPE zif_stock_allocation=>ty_sales_order
        iv_sales_item       TYPE zif_stock_allocation=>ty_sales_item
      RAISING
        zcx_stock_allocation.
  PRIVATE SECTION.
    DATA mo_authorization TYPE REF TO zif_priority_authorization.
    DATA mo_lock TYPE REF TO zif_allocation_lock.
    DATA mo_sink TYPE REF TO zif_priority_sink.
    DATA mo_log TYPE REF TO zif_priority_log.
    METHODS change
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
        iv_sales_order      TYPE zif_stock_allocation=>ty_sales_order
        iv_sales_item       TYPE zif_stock_allocation=>ty_sales_item
        iv_priority         TYPE zif_stock_allocation=>ty_priority
        iv_activity         TYPE zif_priority_authorization=>ty_activity
        iv_remove           TYPE abap_bool
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_priority_service IMPLEMENTATION.
  METHOD constructor.
    ASSERT io_authorization IS BOUND.
    ASSERT io_lock IS BOUND.
    ASSERT io_sink IS BOUND.
    ASSERT io_log IS BOUND.
    mo_authorization = io_authorization.
    mo_lock = io_lock.
    mo_sink = io_sink.
    mo_log = io_log.
  ENDMETHOD.

  METHOD set_priority.
    change(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location
      iv_sales_order = iv_sales_order
      iv_sales_item = iv_sales_item
      iv_priority = iv_priority
      iv_activity = '02'
      iv_remove = abap_false ).
  ENDMETHOD.

  METHOD remove_priority.
    change(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location
      iv_sales_order = iv_sales_order
      iv_sales_item = iv_sales_item
      iv_priority = 0
      iv_activity = '06'
      iv_remove = abap_true ).
  ENDMETHOD.

  METHOD change.
    zcl_stock_alloc_validator=>validate_priority_key(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location
      iv_sales_order = iv_sales_order
      iv_sales_item = iv_sales_item ).
    IF mo_authorization->is_authorized(
         iv_activity = iv_activity
         iv_plant = iv_plant
         iv_storage_location = iv_storage_location ) = abap_false.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Not authorized to maintain stock allocation priorities' ).
    ENDIF.

    DATA(lv_acquired) = mo_lock->acquire(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location ).
    IF lv_acquired = abap_false.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'An allocation run is active for this priority scope' ).
    ENDIF.

    TRY.
        DATA(lv_recorded) = mo_log->record_change(
          iv_material = iv_material
          iv_plant = iv_plant
          iv_storage_location = iv_storage_location
          iv_sales_order = iv_sales_order
          iv_sales_item = iv_sales_item
          iv_priority = iv_priority
          iv_activity = iv_activity ).
        IF lv_recorded = abap_false.
          RAISE EXCEPTION NEW zcx_stock_allocation(
            'Unable to write the priority application log' ).
        ENDIF.
        IF iv_remove = abap_true.
          mo_sink->remove(
            iv_material = iv_material
            iv_plant = iv_plant
            iv_storage_location = iv_storage_location
            iv_sales_order = iv_sales_order
            iv_sales_item = iv_sales_item ).
        ELSE.
          mo_sink->save(
            iv_material = iv_material
            iv_plant = iv_plant
            iv_storage_location = iv_storage_location
            iv_sales_order = iv_sales_order
            iv_sales_item = iv_sales_item
            iv_priority = iv_priority ).
        ENDIF.
      CATCH cx_root INTO DATA(lo_failure).
        mo_lock->release(
          iv_material = iv_material
          iv_plant = iv_plant
          iv_storage_location = iv_storage_location ).
        RAISE EXCEPTION NEW zcx_stock_allocation(
          iv_text = lo_failure->get_text( )
          io_previous = lo_failure ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
