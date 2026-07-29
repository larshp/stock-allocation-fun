CLASS lcl_priority_authorization DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_priority_authorization.
    METHODS constructor
      IMPORTING
        iv_authorized TYPE abap_bool.
    METHODS get_activity
      RETURNING
        VALUE(rv_activity) TYPE zif_priority_authorization=>ty_activity.
  PRIVATE SECTION.
    DATA mv_authorized TYPE abap_bool.
    DATA mv_activity TYPE zif_priority_authorization=>ty_activity.
ENDCLASS.

CLASS lcl_priority_authorization IMPLEMENTATION.
  METHOD constructor.
    mv_authorized = iv_authorized.
  ENDMETHOD.

  METHOD zif_priority_authorization~is_authorized.
    mv_activity = iv_activity.
    rv_authorized = mv_authorized.
  ENDMETHOD.

  METHOD get_activity.
    rv_activity = mv_activity.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_priority_lock DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_lock.
    METHODS constructor
      IMPORTING
        iv_acquired TYPE abap_bool.
    METHODS was_requested
      RETURNING
        VALUE(rv_requested) TYPE abap_bool.
    METHODS was_released
      RETURNING
        VALUE(rv_released) TYPE abap_bool.
  PRIVATE SECTION.
    DATA mv_acquired TYPE abap_bool.
    DATA mv_requested TYPE abap_bool.
    DATA mv_released TYPE abap_bool.
ENDCLASS.

CLASS lcl_priority_lock IMPLEMENTATION.
  METHOD constructor.
    mv_acquired = iv_acquired.
  ENDMETHOD.

  METHOD zif_allocation_lock~acquire.
    mv_requested = abap_true.
    rv_acquired = mv_acquired.
  ENDMETHOD.

  METHOD zif_allocation_lock~release.
    mv_released = abap_true.
  ENDMETHOD.

  METHOD was_requested.
    rv_requested = mv_requested.
  ENDMETHOD.

  METHOD was_released.
    rv_released = mv_released.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_priority_sink DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_priority_sink.
    METHODS constructor
      IMPORTING
        iv_fail TYPE abap_bool.
    METHODS was_saved
      RETURNING
        VALUE(rv_saved) TYPE abap_bool.
    METHODS was_removed
      RETURNING
        VALUE(rv_removed) TYPE abap_bool.
    METHODS get_priority
      RETURNING
        VALUE(rv_priority) TYPE zif_stock_allocation=>ty_priority.
  PRIVATE SECTION.
    DATA mv_fail TYPE abap_bool.
    DATA mv_saved TYPE abap_bool.
    DATA mv_removed TYPE abap_bool.
    DATA mv_priority TYPE zif_stock_allocation=>ty_priority.
ENDCLASS.

CLASS lcl_priority_sink IMPLEMENTATION.
  METHOD constructor.
    mv_fail = iv_fail.
  ENDMETHOD.

  METHOD zif_priority_sink~save.
    IF mv_fail = abap_true.
      RAISE EXCEPTION NEW cx_sy_zerodivide( ).
    ENDIF.
    mv_saved = abap_true.
    mv_priority = iv_priority.
  ENDMETHOD.

  METHOD zif_priority_sink~remove.
    IF mv_fail = abap_true.
      RAISE EXCEPTION NEW cx_sy_zerodivide( ).
    ENDIF.
    mv_removed = abap_true.
  ENDMETHOD.

  METHOD was_saved.
    rv_saved = mv_saved.
  ENDMETHOD.

  METHOD was_removed.
    rv_removed = mv_removed.
  ENDMETHOD.

  METHOD get_priority.
    rv_priority = mv_priority.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_priority_service DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS saves_authorized_priority FOR TESTING RAISING zcx_stock_allocation.
    METHODS removes_authorized_priority FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_unauthorized_change FOR TESTING.
    METHODS releases_lock_on_failure FOR TESTING.
    METHODS rejects_invalid_key_first FOR TESTING.
ENDCLASS.

CLASS ltcl_priority_service IMPLEMENTATION.
  METHOD saves_authorized_priority.
    DATA(lo_authorization) = NEW lcl_priority_authorization( abap_true ).
    DATA(lo_lock) = NEW lcl_priority_lock( abap_true ).
    DATA(lo_sink) = NEW lcl_priority_sink( abap_false ).
    DATA(lo_service) = NEW zcl_priority_service(
      io_authorization = lo_authorization
      io_lock = lo_lock
      io_sink = lo_sink ).

    lo_service->set_priority(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_storage_location = '0001'
      iv_sales_order = '1'
      iv_sales_item = '000010'
      iv_priority = 25 ).

    cl_abap_unit_assert=>assert_true( lo_sink->was_saved( ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_sink->get_priority( ) exp = 25 ).
    cl_abap_unit_assert=>assert_equals( act = lo_authorization->get_activity( ) exp = '02' ).
    cl_abap_unit_assert=>assert_true( lo_lock->was_requested( ) ).
    cl_abap_unit_assert=>assert_false( lo_lock->was_released( ) ).
  ENDMETHOD.

  METHOD removes_authorized_priority.
    DATA(lo_authorization) = NEW lcl_priority_authorization( abap_true ).
    DATA(lo_sink) = NEW lcl_priority_sink( abap_false ).
    DATA(lo_service) = NEW zcl_priority_service(
      io_authorization = lo_authorization
      io_lock = NEW lcl_priority_lock( abap_true )
      io_sink = lo_sink ).

    lo_service->remove_priority(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_storage_location = '0001'
      iv_sales_order = '1'
      iv_sales_item = '000010' ).

    cl_abap_unit_assert=>assert_true( lo_sink->was_removed( ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_authorization->get_activity( ) exp = '06' ).
  ENDMETHOD.

  METHOD rejects_unauthorized_change.
    DATA(lo_lock) = NEW lcl_priority_lock( abap_true ).
    DATA(lo_sink) = NEW lcl_priority_sink( abap_false ).
    DATA(lo_service) = NEW zcl_priority_service(
      io_authorization = NEW lcl_priority_authorization( abap_false )
      io_lock = lo_lock
      io_sink = lo_sink ).

    TRY.
        lo_service->set_priority(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_storage_location = '0001'
          iv_sales_order = '1'
          iv_sales_item = '000010'
          iv_priority = 10 ).
        cl_abap_unit_assert=>fail( 'Unauthorized priority change must fail' ).
      CATCH zcx_stock_allocation.
        cl_abap_unit_assert=>assert_false( lo_lock->was_requested( ) ).
        cl_abap_unit_assert=>assert_false( lo_sink->was_saved( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD releases_lock_on_failure.
    DATA(lo_lock) = NEW lcl_priority_lock( abap_true ).
    DATA(lo_service) = NEW zcl_priority_service(
      io_authorization = NEW lcl_priority_authorization( abap_true )
      io_lock = lo_lock
      io_sink = NEW lcl_priority_sink( abap_true ) ).

    TRY.
        lo_service->set_priority(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_storage_location = '0001'
          iv_sales_order = '1'
          iv_sales_item = '000010'
          iv_priority = 10 ).
        cl_abap_unit_assert=>fail( 'Priority persistence failure must propagate' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_true( lo_lock->was_released( ) ).
        cl_abap_unit_assert=>assert_bound( lo_error->previous ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_invalid_key_first.
    DATA(lo_authorization) = NEW lcl_priority_authorization( abap_true ).
    DATA(lo_lock) = NEW lcl_priority_lock( abap_true ).
    DATA(lo_sink) = NEW lcl_priority_sink( abap_false ).
    DATA(lo_service) = NEW zcl_priority_service(
      io_authorization = lo_authorization
      io_lock = lo_lock
      io_sink = lo_sink ).

    TRY.
        lo_service->set_priority(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_storage_location = '0001'
          iv_sales_order = ''
          iv_sales_item = '000010'
          iv_priority = 10 ).
        cl_abap_unit_assert=>fail( 'Invalid priority key must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_initial( lo_authorization->get_activity( ) ).
    cl_abap_unit_assert=>assert_false( lo_lock->was_requested( ) ).
    cl_abap_unit_assert=>assert_false( lo_sink->was_saved( ) ).
  ENDMETHOD.
ENDCLASS.
