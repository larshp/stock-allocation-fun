CLASS zcl_allocation_query_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_source        TYPE REF TO zif_allocation_source
        io_authorization TYPE REF TO zif_allocation_authorization.
    METHODS get_saved
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
        iv_max_age_days     TYPE i DEFAULT 1
      RETURNING
        VALUE(rs_saved)     TYPE zif_stock_allocation=>ty_saved_plan
      RAISING
        zcx_stock_allocation.
  PRIVATE SECTION.
    DATA mo_source TYPE REF TO zif_allocation_source.
    DATA mo_authorization TYPE REF TO zif_allocation_authorization.
ENDCLASS.

CLASS zcl_allocation_query_service IMPLEMENTATION.
  METHOD constructor.
    ASSERT io_source IS BOUND.
    ASSERT io_authorization IS BOUND.
    mo_source = io_source.
    mo_authorization = io_authorization.
  ENDMETHOD.

  METHOD get_saved.
    zcl_stock_alloc_validator=>validate_scope(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    IF iv_max_age_days < 0.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Maximum persisted-plan age cannot be negative' ).
    ENDIF.
    IF mo_authorization->is_authorized(
         iv_activity         = '03'
         iv_plant            = iv_plant
         iv_storage_location = iv_storage_location ) = abap_false.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Not authorized to display persisted stock allocations' ).
    ENDIF.
    rs_saved = mo_source->get_saved(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    IF rs_saved-found = abap_true.
      IF rs_saved-created_on IS INITIAL OR rs_saved-created_on > sy-datum.
        RAISE EXCEPTION NEW zcx_stock_allocation(
          'Persisted allocation plan has invalid creation date' ).
      ENDIF.
      rs_saved-age_days = sy-datum - rs_saved-created_on.
      rs_saved-stale = xsdbool( rs_saved-age_days > iv_max_age_days ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
