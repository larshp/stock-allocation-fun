CLASS lcl_saved_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_source.
    METHODS constructor
      IMPORTING
        is_saved TYPE zif_stock_allocation=>ty_saved_plan.
    METHODS was_called
      RETURNING
        VALUE(rv_called) TYPE abap_bool.
    METHODS get_version_no
      RETURNING
        VALUE(rv_version_no) TYPE i.
  PRIVATE SECTION.
    DATA ms_saved TYPE zif_stock_allocation=>ty_saved_plan.
    DATA mv_called TYPE abap_bool.
    DATA mv_version_no TYPE i.
ENDCLASS.

CLASS lcl_saved_source IMPLEMENTATION.
  METHOD constructor.
    ms_saved = is_saved.
  ENDMETHOD.

  METHOD zif_allocation_source~get_saved.
    mv_called = abap_true.
    mv_version_no = iv_version_no.
    rs_saved = ms_saved.
  ENDMETHOD.

  METHOD was_called.
    rv_called = mv_called.
  ENDMETHOD.

  METHOD get_version_no.
    rv_version_no = mv_version_no.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_query_authorization DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_authorization.
    METHODS constructor
      IMPORTING
        iv_authorized TYPE abap_bool.
    METHODS get_activity
      RETURNING
        VALUE(rv_activity) TYPE zif_allocation_authorization=>ty_activity.
  PRIVATE SECTION.
    DATA mv_authorized TYPE abap_bool.
    DATA mv_activity TYPE zif_allocation_authorization=>ty_activity.
ENDCLASS.

CLASS lcl_query_authorization IMPLEMENTATION.
  METHOD constructor.
    mv_authorized = iv_authorized.
  ENDMETHOD.

  METHOD zif_allocation_authorization~is_authorized.
    mv_activity = iv_activity.
    rv_authorized = mv_authorized.
  ENDMETHOD.

  METHOD get_activity.
    rv_activity = mv_activity.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_allocation_query_service DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS reads_authorized_snapshot FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_unauthorized_read FOR TESTING.
    METHODS flags_stale_snapshot FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_negative_max_age FOR TESTING.
    METHODS rejects_negative_version FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_query_service IMPLEMENTATION.
  METHOD reads_authorized_snapshot.
    DATA(lo_source) = NEW lcl_saved_source(
      VALUE #(
        found      = abap_true
        plan       = VALUE #( stock_qty = '5' )
        created_on = sy-datum ) ).
    DATA(lo_authorization) = NEW lcl_query_authorization( abap_true ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = lo_authorization ).

    DATA(ls_saved) = lo_service->get_saved(
      iv_material         = 'MAT-1'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_version_no       = 3 ).

    cl_abap_unit_assert=>assert_true( ls_saved-found ).
    cl_abap_unit_assert=>assert_equals( act = ls_saved-plan-stock_qty exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = ls_saved-age_days exp = 0 ).
    cl_abap_unit_assert=>assert_false( ls_saved-stale ).
    cl_abap_unit_assert=>assert_true( lo_source->was_called( ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_source->get_version_no( ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_authorization->get_activity( )
      exp = '03' ).
  ENDMETHOD.

  METHOD rejects_unauthorized_read.
    DATA(lo_source) = NEW lcl_saved_source( VALUE #( ) ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = NEW lcl_query_authorization( abap_false ) ).

    TRY.
        lo_service->get_saved(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Unauthorized persisted-plan read must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_source->was_called( ) ).
  ENDMETHOD.

  METHOD flags_stale_snapshot.
    DATA lv_created_on TYPE d.
    lv_created_on = sy-datum - 2.
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = NEW lcl_saved_source(
        VALUE #( found = abap_true created_on = lv_created_on ) )
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    DATA(ls_saved) = lo_service->get_saved(
      iv_material         = 'MAT-1'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_max_age_days     = 1 ).

    cl_abap_unit_assert=>assert_equals( act = ls_saved-age_days exp = 2 ).
    cl_abap_unit_assert=>assert_true( ls_saved-stale ).
  ENDMETHOD.

  METHOD rejects_negative_max_age.
    DATA(lo_source) = NEW lcl_saved_source( VALUE #( ) ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->get_saved(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_max_age_days     = -1 ).
        cl_abap_unit_assert=>fail( 'Negative maximum age must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_source->was_called( ) ).
  ENDMETHOD.

  METHOD rejects_negative_version.
    DATA(lo_source) = NEW lcl_saved_source( VALUE #( ) ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->get_saved(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_version_no       = -1 ).
        cl_abap_unit_assert=>fail( 'Negative plan version must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_source->was_called( ) ).
  ENDMETHOD.
ENDCLASS.
