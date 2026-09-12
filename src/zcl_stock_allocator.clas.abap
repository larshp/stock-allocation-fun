CLASS zcl_stock_allocator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_quantity TYPE menge_d.
    TYPES ty_material_tt TYPE STANDARD TABLE OF matnr WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_allocation,
             matnr          TYPE matnr,
             requirement_id TYPE c LENGTH 20,
             lgort          TYPE lgort_d,
             charg          TYPE c LENGTH 10,
             expiry_date    TYPE d,
             quantity       TYPE ty_quantity,
           END OF ty_allocation.
    TYPES ty_allocation_tt TYPE STANDARD TABLE OF ty_allocation WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             requirement_id   TYPE c LENGTH 20,
             requested_qty    TYPE ty_quantity,
             allocated_qty    TYPE ty_quantity,
             shortage_qty     TYPE ty_quantity,
             within_tolerance TYPE abap_bool,
             deferred         TYPE abap_bool,
             allocations      TYPE ty_allocation_tt,
           END OF ty_result.
    TYPES ty_result_tt TYPE STANDARD TABLE OF ty_result WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_policy,
             include_quality    TYPE abap_bool,
             include_blocked    TYPE abap_bool,
             include_restricted TYPE abap_bool,
             include_transit    TYPE abap_bool,
             use_fefo           TYPE abap_bool,
             whole_sales_units  TYPE abap_bool,
             max_picks          TYPE i,
             under_tolerance    TYPE i,
             horizon_date       TYPE d,
             safety_stock       TYPE ty_quantity,
           END OF ty_policy.

    METHODS constructor
      IMPORTING
        io_stock_reader  TYPE REF TO zif_stock_reader
        io_uom_converter TYPE REF TO zif_uom_converter OPTIONAL
        io_safety_stock  TYPE REF TO zif_safety_stock OPTIONAL
        is_policy        TYPE ty_policy OPTIONAL.

    METHODS allocate
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
        it_requirements  TYPE zif_requirement_reader=>ty_requirement_tt
      RETURNING
        VALUE(rt_result) TYPE ty_result_tt.

    METHODS allocate_materials
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
        it_materials     TYPE ty_material_tt
        it_requirements  TYPE zif_requirement_reader=>ty_requirement_tt
      RETURNING
        VALUE(rt_result) TYPE ty_result_tt.

    METHODS available_quantity
      IMPORTING
        iv_matnr           TYPE matnr
        iv_werks           TYPE werks_d
      RETURNING
        VALUE(rv_quantity) TYPE ty_quantity.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_taken,
             tabix TYPE i,
             qty   TYPE ty_quantity,
           END OF ty_taken.
    TYPES ty_taken_tt TYPE STANDARD TABLE OF ty_taken WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_available,
             matnr       TYPE matnr,
             lgort       TYPE lgort_d,
             charg       TYPE c LENGTH 10,
             expiry_date TYPE d,
             sort_date   TYPE d,
             quantity    TYPE ty_quantity,
           END OF ty_available.
    TYPES ty_available_tt TYPE STANDARD TABLE OF ty_available WITH DEFAULT KEY.

    DATA mo_stock_reader  TYPE REF TO zif_stock_reader.
    DATA ms_policy        TYPE ty_policy.
    DATA mo_uom_converter TYPE REF TO zif_uom_converter.
    DATA mo_safety_stock  TYPE REF TO zif_safety_stock.

    METHODS to_base_qty
      IMPORTING
        iv_matnr       TYPE matnr
        is_requirement TYPE zif_requirement_reader=>ty_requirement
      RETURNING
        VALUE(rv_qty)  TYPE ty_quantity.

    METHODS sales_unit_step
      IMPORTING
        iv_matnr       TYPE matnr
        is_requirement TYPE zif_requirement_reader=>ty_requirement
      RETURNING
        VALUE(rv_step) TYPE ty_quantity.

    METHODS build_availability
      IMPORTING
        iv_matnr            TYPE matnr
        iv_werks            TYPE werks_d
      RETURNING
        VALUE(rt_available) TYPE ty_available_tt.

    METHODS build_availability_multi
      IMPORTING
        it_materials        TYPE ty_material_tt
        iv_werks            TYPE werks_d
      RETURNING
        VALUE(rt_available) TYPE ty_available_tt.

    METHODS apply_safety_stock
      IMPORTING
        iv_matnr       TYPE matnr
        it_config      TYPE zif_safety_stock=>ty_config_tt
        it_rows        TYPE ty_available_tt
      RETURNING
        VALUE(rt_rows) TYPE ty_available_tt.

    METHODS usable_quantity
      IMPORTING
        is_stock           TYPE zif_stock_reader=>ty_stock
      RETURNING
        VALUE(rv_quantity) TYPE ty_quantity.

ENDCLASS.


CLASS zcl_stock_allocator IMPLEMENTATION.

  METHOD constructor.
    mo_stock_reader = io_stock_reader.
    IF io_uom_converter IS SUPPLIED.
      mo_uom_converter = io_uom_converter.
    ENDIF.
    IF io_safety_stock IS SUPPLIED.
      mo_safety_stock = io_safety_stock.
    ENDIF.
    IF is_policy IS SUPPLIED.
      ms_policy = is_policy.
    ENDIF.
  ENDMETHOD.

  METHOD allocate.
    DATA lt_materials TYPE ty_material_tt.

    APPEND iv_matnr TO lt_materials.

    rt_result = allocate_materials( iv_matnr        = iv_matnr
                                    iv_werks        = iv_werks
                                    it_materials    = lt_materials
                                    it_requirements = it_requirements ).
  ENDMETHOD.

  METHOD allocate_materials.
    DATA lt_available TYPE ty_available_tt.
    DATA lt_sorted    TYPE zif_requirement_reader=>ty_requirement_tt.
    DATA lt_taken     TYPE ty_taken_tt.
    DATA ls_result    TYPE ty_result.
    DATA lv_remaining TYPE ty_quantity.
    DATA lv_take      TYPE ty_quantity.
    DATA lv_step      TYPE ty_quantity.
    DATA lv_picks     TYPE i.
    DATA lv_max_picks TYPE i.

    lv_max_picks = ms_policy-max_picks.

    lt_available = build_availability_multi( it_materials = it_materials
                                             iv_werks     = iv_werks ).

    IF ms_policy-use_fefo = abap_true.
      " earliest expiry first, unknown expiry dates last
      SORT lt_available BY sort_date ASCENDING
                           lgort ASCENDING
                           charg ASCENDING.
    ENDIF.

    lt_sorted = it_requirements.
    SORT lt_sorted BY priority ASCENDING
                      requested_date ASCENDING
                      id ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_requirement).
      CLEAR ls_result.
      ls_result-requirement_id = ls_requirement-id.
      ls_result-requested_qty = to_base_qty( iv_matnr       = iv_matnr
                                             is_requirement = ls_requirement ).

      IF ms_policy-horizon_date IS NOT INITIAL
          AND ls_requirement-requested_date > ms_policy-horizon_date.
        " due after the horizon: leave the requirement for a later run
        ls_result-deferred = abap_true.
        ls_result-shortage_qty = ls_result-requested_qty.
        APPEND ls_result TO rt_result.
        CONTINUE.
      ENDIF.

      lv_remaining = ls_result-requested_qty.
      lv_step = sales_unit_step( iv_matnr       = iv_matnr
                                 is_requirement = ls_requirement ).
      CLEAR lt_taken.
      lv_picks = 0.

      LOOP AT lt_available ASSIGNING FIELD-SYMBOL(<ls_available>).
        IF lv_remaining <= 0.
          EXIT.
        ENDIF.
        IF <ls_available>-quantity <= 0.
          CONTINUE.
        ENDIF.
        IF lv_max_picks > 0 AND lv_picks >= lv_max_picks.
          EXIT.
        ENDIF.

        lv_take = <ls_available>-quantity.
        IF lv_take > lv_remaining.
          lv_take = lv_remaining.
        ENDIF.

        IF lv_step > 0.
          " only whole sales units may be taken from a single stock row
          lv_take = lv_take DIV lv_step.
          lv_take = lv_take * lv_step.
        ENDIF.
        IF lv_take <= 0.
          CONTINUE.
        ENDIF.

        APPEND VALUE #( tabix = sy-tabix
                        qty   = lv_take ) TO lt_taken.
        lv_picks = lv_picks + 1.

        APPEND VALUE #( matnr          = <ls_available>-matnr
                        requirement_id = ls_requirement-id
                        lgort          = <ls_available>-lgort
                        charg          = <ls_available>-charg
                        expiry_date    = <ls_available>-expiry_date
                        quantity       = lv_take ) TO ls_result-allocations.

        <ls_available>-quantity = <ls_available>-quantity - lv_take.
        lv_remaining = lv_remaining - lv_take.
      ENDLOOP.

      IF lv_max_picks > 0 AND lv_remaining > 0.
        " the requirement cannot be covered within the pick limit: skip it
        " completely and give the reserved stock back
        LOOP AT lt_taken INTO DATA(ls_taken).
          READ TABLE lt_available ASSIGNING FIELD-SYMBOL(<ls_give_back>)
            INDEX ls_taken-tabix.
          IF sy-subrc = 0.
            <ls_give_back>-quantity = <ls_give_back>-quantity + ls_taken-qty.
          ENDIF.
        ENDLOOP.

        CLEAR ls_result-allocations.
        lv_remaining = ls_result-requested_qty.
      ENDIF.

      ls_result-allocated_qty = ls_result-requested_qty - lv_remaining.
      ls_result-shortage_qty  = lv_remaining.

      IF ls_result-shortage_qty > 0
          AND ms_policy-under_tolerance > 0
          AND ls_result-requested_qty > 0
          AND ls_result-shortage_qty * 100 DIV ls_result-requested_qty
              <= ms_policy-under_tolerance.
        ls_result-within_tolerance = abap_true.
      ENDIF.

      APPEND ls_result TO rt_result.
    ENDLOOP.
  ENDMETHOD.

  METHOD available_quantity.
    DATA lt_available TYPE ty_available_tt.

    lt_available = build_availability( iv_matnr = iv_matnr
                                       iv_werks = iv_werks ).

    LOOP AT lt_available INTO DATA(ls_available).
      rv_quantity = rv_quantity + ls_available-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD to_base_qty.
    rv_qty = is_requirement-requested_qty.
    IF is_requirement-unit IS INITIAL OR mo_uom_converter IS NOT BOUND.
      RETURN.
    ENDIF.

    rv_qty = mo_uom_converter->to_base_qty(
      iv_matnr = iv_matnr
      iv_meinh = is_requirement-unit
      iv_qty   = is_requirement-requested_qty ).
  ENDMETHOD.

  METHOD sales_unit_step.
    rv_step = 0.

    IF ms_policy-whole_sales_units <> abap_true
        OR is_requirement-unit IS INITIAL
        OR mo_uom_converter IS NOT BOUND.
      RETURN.
    ENDIF.

    rv_step = mo_uom_converter->to_base_qty( iv_matnr = iv_matnr
                                             iv_meinh = is_requirement-unit
                                             iv_qty   = 1 ).
    IF rv_step <= 0.
      rv_step = 0.
    ENDIF.
  ENDMETHOD.

  METHOD build_availability.
    DATA lt_materials TYPE ty_material_tt.

    APPEND iv_matnr TO lt_materials.

    rt_available = build_availability_multi( it_materials = lt_materials
                                             iv_werks     = iv_werks ).
  ENDMETHOD.

  METHOD build_availability_multi.
    DATA lt_stock  TYPE zif_stock_reader=>ty_stock_tt.
    DATA lt_rows   TYPE ty_available_tt.
    DATA lt_config TYPE zif_safety_stock=>ty_config_tt.
    DATA lv_usable TYPE ty_quantity.
    DATA lv_expiry TYPE d.
    DATA lv_safety TYPE ty_quantity.

    LOOP AT it_materials INTO DATA(lv_matnr_value).
      CLEAR lt_rows.

      lt_stock = mo_stock_reader->read_stock( iv_matnr = lv_matnr_value
                                              iv_werks = iv_werks ).

      LOOP AT lt_stock INTO DATA(ls_stock).
        lv_usable = usable_quantity( ls_stock ).
        IF lv_usable <= 0.
          CONTINUE.
        ENDIF.

        lv_expiry = ls_stock-expiry_date.
        IF lv_expiry IS INITIAL.
          lv_expiry = '99991231'.
        ENDIF.

        APPEND VALUE #( matnr       = ls_stock-matnr
                        lgort       = ls_stock-lgort
                        charg       = ls_stock-charg
                        expiry_date = ls_stock-expiry_date
                        sort_date   = lv_expiry
                        quantity    = lv_usable ) TO lt_rows.
      ENDLOOP.

      IF mo_safety_stock IS BOUND.
        " keep the configured safety stock in its storage location
        lt_config = mo_safety_stock->read( iv_matnr = lv_matnr_value
                                           iv_werks = iv_werks ).
        lt_rows = apply_safety_stock( iv_matnr  = lv_matnr_value
                                      it_config = lt_config
                                      it_rows   = lt_rows ).
      ENDIF.

      APPEND LINES OF lt_rows TO rt_available.
    ENDLOOP.

    lv_safety = ms_policy-safety_stock.
    IF lv_safety > 0.
      " keep the safety stock in the bins, it is not available for allocation
      LOOP AT rt_available ASSIGNING FIELD-SYMBOL(<ls_available>).
        IF lv_safety <= 0.
          EXIT.
        ENDIF.

        IF <ls_available>-quantity <= lv_safety.
          lv_safety = lv_safety - <ls_available>-quantity.
          CLEAR <ls_available>-quantity.
        ELSE.
          <ls_available>-quantity = <ls_available>-quantity - lv_safety.
          CLEAR lv_safety.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD apply_safety_stock.
    DATA lv_remaining TYPE ty_quantity.

    rt_rows = it_rows.

    LOOP AT it_config INTO DATA(ls_config).
      IF ls_config-qty <= 0.
        CONTINUE.
      ENDIF.

      lv_remaining = ls_config-qty.

      LOOP AT rt_rows ASSIGNING FIELD-SYMBOL(<ls_row>).
        IF lv_remaining <= 0.
          EXIT.
        ENDIF.
        IF <ls_row>-matnr <> iv_matnr.
          CONTINUE.
        ENDIF.
        IF ls_config-lgort IS NOT INITIAL
            AND <ls_row>-lgort <> ls_config-lgort.
          CONTINUE.
        ENDIF.
        IF <ls_row>-quantity <= 0.
          CONTINUE.
        ENDIF.

        IF <ls_row>-quantity <= lv_remaining.
          lv_remaining = lv_remaining - <ls_row>-quantity.
          CLEAR <ls_row>-quantity.
        ELSE.
          <ls_row>-quantity = <ls_row>-quantity - lv_remaining.
          CLEAR lv_remaining.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD usable_quantity.
    rv_quantity = is_stock-unrestricted_qty.

    IF ms_policy-include_quality = abap_true.
      rv_quantity = rv_quantity + is_stock-quality_qty.
    ENDIF.
    IF ms_policy-include_blocked = abap_true.
      rv_quantity = rv_quantity + is_stock-blocked_qty.
    ENDIF.
    IF ms_policy-include_restricted = abap_true.
      rv_quantity = rv_quantity + is_stock-restricted_qty.
    ENDIF.
    IF ms_policy-include_transit = abap_true.
      rv_quantity = rv_quantity + is_stock-in_transit_qty.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
