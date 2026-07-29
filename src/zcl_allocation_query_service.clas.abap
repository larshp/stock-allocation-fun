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
        iv_version_no       TYPE i OPTIONAL
      RETURNING
        VALUE(rs_saved)     TYPE zif_stock_allocation=>ty_saved_plan
      RAISING
        zcx_stock_allocation.
    METHODS list_versions
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
        iv_max_versions     TYPE i DEFAULT 20
        iv_before_version   TYPE i OPTIONAL
        iv_created_from     TYPE d OPTIONAL
        iv_created_to       TYPE d OPTIONAL
        iv_shortages_only   TYPE abap_bool OPTIONAL
        iv_strategy         TYPE zif_stock_allocation=>ty_strategy OPTIONAL
        iv_created_by       TYPE zif_stock_allocation=>ty_created_by OPTIONAL
      RETURNING
        VALUE(rt_versions)  TYPE zif_stock_allocation=>tt_plan_versions
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
    IF iv_version_no < 0.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Persisted allocation plan version cannot be negative' ).
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
      iv_storage_location = iv_storage_location
      iv_version_no       = iv_version_no ).
    IF rs_saved-found = abap_true.
      IF rs_saved-version_no <= 0
          OR rs_saved-plan-version_no <> rs_saved-version_no
          OR ( iv_version_no > 0
            AND rs_saved-version_no <> iv_version_no ).
        RAISE EXCEPTION NEW zcx_stock_allocation(
          'Persisted allocation source returned an inconsistent version' ).
      ENDIF.
      IF rs_saved-created_on IS INITIAL
          OR rs_saved-created_on > sy-datum
          OR rs_saved-created_by IS INITIAL.
        RAISE EXCEPTION NEW zcx_stock_allocation(
          'Persisted allocation plan has invalid creation provenance' ).
      ENDIF.
      rs_saved-age_days = sy-datum - rs_saved-created_on.
      rs_saved-stale = xsdbool( rs_saved-age_days > iv_max_age_days ).
    ENDIF.
  ENDMETHOD.

  METHOD list_versions.
    zcl_stock_alloc_validator=>validate_scope(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    IF iv_max_versions <= 0 OR iv_max_versions > 100.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Historical version list size must be between 1 and 100' ).
    ENDIF.
    IF iv_before_version < 0.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Historical version cursor cannot be negative' ).
    ENDIF.
    IF iv_created_from IS NOT INITIAL
        AND iv_created_to IS NOT INITIAL
        AND iv_created_from > iv_created_to.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'History creation start cannot be after its end date' ).
    ENDIF.
    IF iv_strategy IS NOT INITIAL.
      zcl_stock_alloc_validator=>validate_strategy( iv_strategy ).
    ENDIF.
    IF mo_authorization->is_authorized(
         iv_activity         = '03'
         iv_plant            = iv_plant
         iv_storage_location = iv_storage_location ) = abap_false.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Not authorized to display persisted stock allocations' ).
    ENDIF.
    rt_versions = mo_source->list_versions(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location
      iv_max_versions     = iv_max_versions
      iv_before_version   = iv_before_version
      iv_created_from     = iv_created_from
      iv_created_to       = iv_created_to
      iv_shortages_only   = iv_shortages_only
      iv_strategy         = iv_strategy
      iv_created_by       = iv_created_by ).
    IF lines( rt_versions ) > iv_max_versions.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Historical version source exceeded the requested list size' ).
    ENDIF.
    DATA lv_previous_version TYPE i.
    DATA lt_checked_versions TYPE zif_stock_allocation=>tt_plan_versions.
    LOOP AT rt_versions INTO DATA(ls_version).
      zcl_stock_alloc_validator=>validate_strategy( ls_version-strategy ).
      zcl_stock_alloc_validator=>validate_window(
        iv_start_date  = ls_version-start_date
        iv_cutoff_date = ls_version-cutoff_date ).
      DATA lv_expected_allocatable TYPE zif_stock_allocation=>ty_quantity.
      lv_expected_allocatable = ls_version-stock_qty - ls_version-reserve_qty.
      IF lv_expected_allocatable < 0.
        CLEAR lv_expected_allocatable.
      ENDIF.
      IF ls_version-version_no <= 0
          OR ls_version-created_on IS INITIAL
          OR ls_version-created_on > sy-datum
          OR ls_version-created_by IS INITIAL
          OR ls_version-stock_qty < 0
          OR ls_version-reserve_qty < 0
          OR ls_version-allocatable_qty < 0
          OR ls_version-allocatable_qty <> lv_expected_allocatable
          OR ls_version-unit IS INITIAL
          OR ls_version-requested_qty < 0
          OR ls_version-allocated_qty < 0
          OR ls_version-allocated_qty > ls_version-allocatable_qty
          OR ls_version-shortage_qty < 0
          OR ls_version-requested_qty
            <> ls_version-allocated_qty + ls_version-shortage_qty
          OR ls_version-full_count < 0
          OR ls_version-partial_count < 0
          OR ls_version-none_count < 0
          OR ( iv_strategy IS NOT INITIAL
            AND ls_version-strategy <> iv_strategy )
          OR ( iv_created_by IS NOT INITIAL
            AND ls_version-created_by <> iv_created_by )
          OR ls_version-demand_count
            <> ls_version-full_count
             + ls_version-partial_count
             + ls_version-none_count
          OR ( lv_previous_version IS NOT INITIAL
            AND ls_version-version_no >= lv_previous_version ).
        RAISE EXCEPTION NEW zcx_stock_allocation(
          'Persisted allocation history catalog is inconsistent' ).
      ENDIF.
      ls_version-age_days = sy-datum - ls_version-created_on.
      lv_previous_version = ls_version-version_no.
      APPEND ls_version TO lt_checked_versions.
    ENDLOOP.
    rt_versions = lt_checked_versions.
  ENDMETHOD.
ENDCLASS.
