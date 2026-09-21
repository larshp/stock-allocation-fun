CLASS zcl_stock_source_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_authority TYPE REF TO zif_source_read_authority OPTIONAL.
    INTERFACES zif_stock_source.
  PRIVATE SECTION.
    DATA mo_authority TYPE REF TO zif_source_read_authority.
    TYPES:
      BEGIN OF ty_reservation_row,
        reservation_id     TYPE zif_stock_allocation=>ty_reservation_id,
        batch              TYPE zif_stock_allocation=>ty_batch,
        required_quantity  TYPE zif_stock_allocation=>ty_quantity,
        withdrawn_quantity TYPE zif_stock_allocation=>ty_quantity,
        unit               TYPE zif_stock_allocation=>ty_unit,
        final_issue        TYPE resb-kzear,
        deletion_indicator TYPE resb-xloek,
      END OF ty_reservation_row.
    TYPES tt_reservation_rows TYPE STANDARD TABLE OF ty_reservation_row
      WITH EMPTY KEY.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_source_sap IMPLEMENTATION.
  METHOD constructor.
    IF io_authority IS BOUND.
      mo_authority = io_authority.
    ELSE.
      CREATE OBJECT mo_authority TYPE zcl_source_read_auth_sap.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_source~get_available.
    DATA lv_stock_deleted TYPE c LENGTH 1.
    DATA lv_material_deleted TYPE c LENGTH 1.
    DATA lv_plant_material_deleted TYPE c LENGTH 1.
    DATA lv_batch_global_deleted TYPE c LENGTH 1.
    DATA lv_batch_global_restricted TYPE c LENGTH 1.
    DATA lv_batch_plant_deleted TYPE c LENGTH 1.
    DATA lv_batch_plant_restricted TYPE c LENGTH 1.
    DATA lv_batch_global_expiration TYPE d.
    DATA lv_batch_plant_expiration TYPE d.
    DATA lv_batch_global_found TYPE abap_bool.
    DATA lv_batch_plant_found TYPE abap_bool.
    DATA lv_storage_location TYPE t001l-lgort.
    DATA lt_reservations TYPE tt_reservation_rows.
    DATA lv_open_quantity TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_reserved_quantity TYPE zif_stock_allocation=>ty_quantity.
    DATA ls_reusable_reservation TYPE zif_stock_allocation=>ty_reservation_open.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      raise_error( iv_message = 'Stock read scope is incomplete' ).
    ENDIF.
    IF iv_include_reservations <> abap_true
        AND iv_include_reservations <> abap_false.
      raise_error( iv_message = 'Reservation inclusion flag is invalid' ).
    ENDIF.
    IF mo_authority IS BOUND.
      TRY.
          mo_authority->check_stock(
            iv_plant                = iv_plant
            iv_batch                = iv_batch
            iv_include_reservations = iv_include_reservations ).
        CATCH zcx_stock_allocation INTO DATA(lo_authority_error).
          IF lo_authority_error->message IS INITIAL.
            lo_authority_error->message = 'Stock read authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_authority_error.
      ENDTRY.
    ENDIF.
    SELECT SINGLE lgort
      FROM t001l
      WHERE werks = @iv_plant
        AND lgort = @iv_storage_location
        INTO @lv_storage_location.
    IF sy-subrc <> 0.
      raise_error(
        iv_message = 'Storage location is invalid for plant' ).
    ENDIF.
    IF iv_batch IS INITIAL.
      CLEAR lv_stock_deleted.
      SELECT SINGLE labst, lvorm
        FROM mard

        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location INTO ( @rs_available-quantity, @lv_stock_deleted ).
    ELSE.
      CLEAR lv_stock_deleted.
      SELECT SINGLE clabs, lvorm
        FROM mchb

        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND charg = @iv_batch INTO ( @rs_available-quantity, @lv_stock_deleted ).
    ENDIF.
    IF sy-subrc <> 0.
      CLEAR rs_available-quantity.
    ELSEIF lv_stock_deleted <> abap_true
        AND lv_stock_deleted <> abap_false.
      raise_error( iv_message = 'Stock deletion flag is invalid' ).
    ELSEIF lv_stock_deleted = 'X'.
      raise_error( iv_message = 'Stock record is marked for deletion' ).
    ENDIF.
    IF rs_available-quantity < 0.
      raise_error( iv_message = 'Stock quantity is invalid' ).
    ENDIF.
    rs_available-unrestricted_quantity = rs_available-quantity.
    SELECT SINGLE meins, xchpf, lvorm
      FROM mara

      WHERE matnr = @iv_material INTO ( @rs_available-unit, @rs_available-batch_managed, @lv_material_deleted ).
    IF sy-subrc <> 0.
      CLEAR: rs_available-unit,
             rs_available-material_found,
             rs_available-batch_managed.
    ELSE.
      IF lv_material_deleted <> abap_true
          AND lv_material_deleted <> abap_false.
        raise_error( iv_message = 'Material deletion flag is invalid' ).
      ENDIF.
      IF lv_material_deleted = 'X'.
        raise_error( iv_message = 'Material is marked for deletion' ).
      ENDIF.
      IF rs_available-batch_managed <> abap_true
          AND rs_available-batch_managed <> abap_false.
        raise_error( iv_message = 'Material batch-management flag is invalid' ).
      ENDIF.
      rs_available-unit = to_upper( rs_available-unit ).
      rs_available-material_found = abap_true.
      IF rs_available-unit IS INITIAL.
        raise_error( iv_message = 'Material base unit is missing' ).
      ENDIF.
    ENDIF.
    IF iv_include_reservations = abap_true.
      IF iv_batch IS INITIAL.
        SELECT rsnum AS reservation_id,
               charg AS batch,
               bdmng AS required_quantity,
               enmng AS withdrawn_quantity,
               meins AS unit,
               kzear AS final_issue,
               xloek AS deletion_indicator
          FROM resb
          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND sobkz = @space
          INTO CORRESPONDING FIELDS OF TABLE @lt_reservations.
      ELSE.
        SELECT rsnum AS reservation_id,
               charg AS batch,
               bdmng AS required_quantity,
               enmng AS withdrawn_quantity,
               meins AS unit,
               kzear AS final_issue,
               xloek AS deletion_indicator
          FROM resb
          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND sobkz = @space
            AND charg = @iv_batch
          INTO CORRESPONDING FIELDS OF TABLE @lt_reservations.
      ENDIF.

      LOOP AT lt_reservations ASSIGNING FIELD-SYMBOL(<ls_reservation>).
        IF <ls_reservation>-final_issue <> abap_true
            AND <ls_reservation>-final_issue <> abap_false.
          raise_error( iv_message = 'Reservation final-issue flag is invalid' ).
        ENDIF.
        IF <ls_reservation>-deletion_indicator <> abap_true
            AND <ls_reservation>-deletion_indicator <> abap_false.
          raise_error( iv_message = 'Reservation deletion flag is invalid' ).
        ENDIF.
        IF <ls_reservation>-deletion_indicator = abap_true.
          CONTINUE.
        ENDIF.
        IF line_exists( it_app_reservation_ids[
              table_line = <ls_reservation>-reservation_id ] ).
          INSERT <ls_reservation>-reservation_id
            INTO TABLE rs_available-sap_accounted_reservations.
        ENDIF.
        IF <ls_reservation>-final_issue = abap_true.
          CONTINUE.
        ENDIF.
        IF <ls_reservation>-required_quantity < 0
            OR <ls_reservation>-withdrawn_quantity < 0
            OR <ls_reservation>-withdrawn_quantity
              > <ls_reservation>-required_quantity.
          raise_error( iv_message = 'Reservation quantity is invalid' ).
        ENDIF.
        lv_open_quantity = <ls_reservation>-required_quantity
          - <ls_reservation>-withdrawn_quantity.
        IF lv_open_quantity = 0.
          CONTINUE.
        ENDIF.
        IF rs_available-material_found <> abap_true
            OR <ls_reservation>-unit IS INITIAL
            OR to_upper( <ls_reservation>-unit ) <> rs_available-unit.
          raise_error( iv_message = 'Reservation unit is invalid' ).
        ENDIF.
        IF lv_open_quantity > zif_stock_allocation=>c_max_quantity
            - lv_reserved_quantity.
          raise_error( iv_message = 'Reservation quantity total is out of range' ).
        ENDIF.
        lv_reserved_quantity = lv_reserved_quantity + lv_open_quantity.
        IF line_exists( it_app_reservation_ids[
              table_line = <ls_reservation>-reservation_id ] ).
          READ TABLE rs_available-reusable_reservations
            ASSIGNING FIELD-SYMBOL(<ls_reusable_reservation>)
            WITH TABLE KEY reservation_id = <ls_reservation>-reservation_id.
          IF sy-subrc = 0.
            IF lv_open_quantity
                > zif_stock_allocation=>c_max_quantity
                  - <ls_reusable_reservation>-quantity.
              raise_error(
                iv_message = 'Reusable reservation quantity is out of range' ).
            ENDIF.
            <ls_reusable_reservation>-quantity =
              <ls_reusable_reservation>-quantity + lv_open_quantity.
          ELSE.
            CLEAR ls_reusable_reservation.
            ls_reusable_reservation-reservation_id =
              <ls_reservation>-reservation_id.
            ls_reusable_reservation-quantity = lv_open_quantity.
            INSERT ls_reusable_reservation
              INTO TABLE rs_available-reusable_reservations.
          ENDIF.
        ENDIF.
      ENDLOOP.

      rs_available-unrestricted_quantity = rs_available-quantity.
      rs_available-reservation_quantity = lv_reserved_quantity.
      rs_available-reservations_included = abap_true.
      IF lv_reserved_quantity >= rs_available-quantity.
        CLEAR rs_available-quantity.
      ELSE.
        rs_available-quantity = rs_available-quantity
          - lv_reserved_quantity.
      ENDIF.
    ENDIF.
    CLEAR lv_plant_material_deleted.
    SELECT SINGLE lvorm
      FROM marc
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        INTO @lv_plant_material_deleted.
    IF sy-subrc <> 0.
      IF rs_available-material_found = abap_true.
        raise_error( iv_message = 'Plant material data is missing' ).
      ENDIF.
    ELSE.
      IF lv_plant_material_deleted <> abap_true
          AND lv_plant_material_deleted <> abap_false.
        raise_error( iv_message = 'Plant material deletion flag is invalid' ).
      ELSEIF lv_plant_material_deleted = abap_true.
        raise_error( iv_message = 'Material is marked for deletion at plant' ).
      ENDIF.
    ENDIF.
    IF iv_batch IS NOT INITIAL.
      CLEAR: lv_batch_global_deleted,
             lv_batch_global_restricted,
             lv_batch_global_expiration,
             lv_batch_global_found.
      SELECT SINGLE vfdat, zustd, lvorm
        FROM mch1
        WHERE matnr = @iv_material
          AND charg = @iv_batch
          INTO ( @lv_batch_global_expiration,
                 @lv_batch_global_restricted,
                 @lv_batch_global_deleted ).
      IF sy-subrc = 0.
        lv_batch_global_found = abap_true.
        IF lv_batch_global_deleted <> abap_true
            AND lv_batch_global_deleted <> abap_false.
          raise_error( iv_message = 'Global batch deletion flag is invalid' ).
        ENDIF.
        IF lv_batch_global_deleted = abap_true.
          raise_error( iv_message = 'Batch master data is marked for deletion' ).
        ENDIF.
        IF lv_batch_global_restricted <> abap_true
            AND lv_batch_global_restricted <> abap_false.
          raise_error( iv_message = 'Batch restriction flag is invalid' ).
        ENDIF.
        IF zcl_allocation_date_sap=>is_valid_or_initial(
             lv_batch_global_expiration ) <> abap_true.
          raise_error( iv_message = 'Batch expiration date is invalid' ).
        ENDIF.
      ENDIF.

      CLEAR: lv_batch_plant_deleted,
             lv_batch_plant_restricted,
             lv_batch_plant_expiration,
             lv_batch_plant_found.
      SELECT SINGLE vfdat, zustd, lvorm
        FROM mcha
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND charg = @iv_batch
          INTO ( @lv_batch_plant_expiration,
                 @lv_batch_plant_restricted,
                 @lv_batch_plant_deleted ).
      IF sy-subrc = 0.
        lv_batch_plant_found = abap_true.
        IF lv_batch_plant_deleted <> abap_true
            AND lv_batch_plant_deleted <> abap_false.
          raise_error( iv_message = 'Batch deletion flag is invalid' ).
        ENDIF.
        IF lv_batch_plant_deleted = abap_true.
          raise_error( iv_message = 'Batch master data is marked for deletion' ).
        ENDIF.
        IF lv_batch_plant_restricted <> abap_true
            AND lv_batch_plant_restricted <> abap_false.
          raise_error( iv_message = 'Batch restriction flag is invalid' ).
        ENDIF.
        IF zcl_allocation_date_sap=>is_valid_or_initial(
             lv_batch_plant_expiration ) <> abap_true.
          raise_error( iv_message = 'Batch expiration date is invalid' ).
        ENDIF.
      ENDIF.

      IF lv_batch_global_found <> abap_true
          AND lv_batch_plant_found <> abap_true
          AND rs_available-batch_managed = abap_true.
        raise_error( iv_message = 'Batch master data is missing' ).
      ENDIF.
      IF lv_batch_global_expiration IS NOT INITIAL.
        rs_available-batch_expiration_date = lv_batch_global_expiration.
      ELSE.
        rs_available-batch_expiration_date = lv_batch_plant_expiration.
      ENDIF.
      IF lv_batch_global_restricted = abap_true
          OR lv_batch_plant_restricted = abap_true.
        rs_available-batch_restricted = abap_true.
      ELSE.
        rs_available-batch_restricted = abap_false.
      ENDIF.
      IF lv_batch_global_found = abap_true
          OR lv_batch_plant_found = abap_true.
        rs_available-batch_found = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
