CLASS ltcl_sto_demand_reader DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr   TYPE ekpo-matnr VALUE 'STO-DEMAND-01'.
    CONSTANTS c_matnr_2 TYPE ekpo-matnr VALUE 'STO-DEMAND-02'.
    CONSTANTS c_werks   TYPE mard-werks VALUE '1000'.
    CONSTANTS c_werks_2 TYPE mard-werks VALUE '2000'.

    DATA mo_cut TYPE REF TO zif_demand_reader.

    METHODS setup.
    METHODS teardown.

    "! A stock transport order taking IV_MATNR out of C_WERKS, with one
    "! schedule line unless IV_SCHEDULED is switched off.
    METHODS given_transfer
      IMPORTING
        iv_ebeln     TYPE ekko-ebeln
        iv_menge     TYPE ekpo-menge
        iv_reswk     TYPE ekko-reswk DEFAULT c_werks
        iv_matnr     TYPE ekpo-matnr DEFAULT c_matnr
        iv_meins     TYPE ekpo-meins DEFAULT 'PC'
        iv_eindt     TYPE eket-eindt DEFAULT '20260201'
        iv_issued    TYPE eket-wamng DEFAULT 0
        iv_scheduled TYPE abap_bool DEFAULT abap_true
        iv_deleted   TYPE abap_bool DEFAULT abap_false
        iv_complete  TYPE abap_bool DEFAULT abap_false.

    METHODS given_schedule_line
      IMPORTING
        iv_ebeln  TYPE eket-ebeln
        iv_etenr  TYPE eket-etenr
        iv_menge  TYPE eket-menge
        iv_eindt  TYPE eket-eindt
        iv_issued TYPE eket-wamng DEFAULT 0.

    METHODS reads_an_open_transfer FOR TESTING RAISING cx_static_check.
    METHODS issued_part_is_off_demand FOR TESTING RAISING cx_static_check.
    METHODS fully_issued_drops_out FOR TESTING RAISING cx_static_check.
    METHODS schedule_lines_add_up FOR TESTING RAISING cx_static_check.
    METHODS earliest_date_is_the_date FOR TESTING RAISING cx_static_check.
    METHODS unscheduled_item_still_counts FOR TESTING RAISING cx_static_check.
    METHODS other_supplying_plant_is_out FOR TESTING RAISING cx_static_check.
    METHODS deleted_item_is_out FOR TESTING RAISING cx_static_check.
    METHODS completed_item_is_out FOR TESTING RAISING cx_static_check.
    METHODS order_unit_becomes_base_unit FOR TESTING RAISING cx_static_check.
    METHODS priority_is_the_one_given FOR TESTING RAISING cx_static_check.
    METHODS lists_materials_with_demand FOR TESTING.

ENDCLASS.


CLASS ltcl_sto_demand_reader IMPLEMENTATION.

  METHOD setup.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_marm TYPE STANDARD TABLE OF marm WITH EMPTY KEY.

    mo_cut = NEW zcl_sto_demand_reader( NEW zcl_unit_converter( ) ).

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'FERT' meins = 'PC' )
      ( mandt = sy-mandt matnr = c_matnr_2 mtart = 'FERT' meins = 'PC' ) ).

    lt_marm = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr meinh = 'CAR' umrez = 12 umren = 1 ) ).

    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'material master fixture could not be inserted' ).

    INSERT marm FROM TABLE @lt_marm.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'unit of measure fixture could not be inserted' ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM eket WHERE ebeln LIKE 'STO-%'.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM ekpo WHERE matnr IN ( @c_matnr, @c_matnr_2 ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM ekko WHERE ebeln LIKE 'STO-%'.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM marm WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr IN ( @c_matnr, @c_matnr_2 ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_transfer.

    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.

    lt_ekko = VALUE #(
      ( mandt = sy-mandt
        ebeln = iv_ebeln
        bsart = 'UB'
        reswk = iv_reswk
        loekz = '' ) ).

    INSERT ekko FROM TABLE @lt_ekko.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'EKKO fixture could not be inserted' ).

    lt_ekpo = VALUE #(
      ( mandt = sy-mandt
        ebeln = iv_ebeln
        ebelp = '00010'
        matnr = iv_matnr
        werks = c_werks_2
        menge = iv_menge
        meins = iv_meins
        loekz = COND #( WHEN iv_deleted = abap_true THEN 'L' )
        elikz = COND #( WHEN iv_complete = abap_true THEN 'X' ) ) ).

    INSERT ekpo FROM TABLE @lt_ekpo.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'EKPO fixture could not be inserted' ).

    IF iv_scheduled = abap_false.
      RETURN.
    ENDIF.

    given_schedule_line(
      iv_ebeln  = iv_ebeln
      iv_etenr  = '0001'
      iv_menge  = iv_menge
      iv_eindt  = iv_eindt
      iv_issued = iv_issued ).

  ENDMETHOD.

  METHOD given_schedule_line.

    DATA lt_eket TYPE STANDARD TABLE OF eket WITH EMPTY KEY.

    lt_eket = VALUE #(
      ( mandt = sy-mandt
        ebeln = iv_ebeln
        ebelp = '00010'
        etenr = iv_etenr
        eindt = iv_eindt
        menge = iv_menge
        wamng = iv_issued ) ).

    INSERT eket FROM TABLE @lt_eket.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'EKET fixture could not be inserted' ).

  ENDMETHOD.

  METHOD reads_an_open_transfer.

    given_transfer(
      iv_ebeln = 'STO-000001'
      iv_menge = '10' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->read_open_demand(
        iv_matnr = c_matnr
        iv_werks = c_werks )
      exp = VALUE zif_allocation=>ty_demand_tab(
        ( demand_id = 'PSTO-00000100010' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260201'
          priority = zcl_sto_demand_reader=>c_default_priority ) )
      msg = 'a transfer out of the plant competes for the plant stock' ).

  ENDMETHOD.

  METHOD issued_part_is_off_demand.

    given_transfer(
      iv_ebeln  = 'STO-000002'
      iv_menge  = '10'
      iv_issued = '2.5' ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-quantity
      exp = '7.5'
      msg = 'what has been issued has left the plant already' ).

  ENDMETHOD.

  METHOD fully_issued_drops_out.

    given_transfer(
      iv_ebeln  = 'STO-000003'
      iv_menge  = '10'
      iv_issued = '10' ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open_demand(
        iv_matnr = c_matnr
        iv_werks = c_werks )
      msg = 'a transfer that has been sent asks for nothing' ).

  ENDMETHOD.

  METHOD schedule_lines_add_up.

    given_transfer(
      iv_ebeln = 'STO-000004'
      iv_menge = '10'
      iv_eindt = '20260201' ).

    given_schedule_line(
      iv_ebeln = 'STO-000004'
      iv_etenr = '0002'
      iv_menge = '4.5'
      iv_eindt = '20260301' ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-quantity
      exp = '14.5'
      msg = 'every schedule line of the item is still to be sent' ).

  ENDMETHOD.

  METHOD earliest_date_is_the_date.

    given_transfer(
      iv_ebeln = 'STO-000005'
      iv_menge = '5'
      iv_eindt = '20260401' ).

    given_schedule_line(
      iv_ebeln = 'STO-000005'
      iv_etenr = '0002'
      iv_menge = '5'
      iv_eindt = '20260210' ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-req_date
      exp = '20260210'
      msg = 'the item is needed when the first part of it is due' ).

  ENDMETHOD.

  METHOD unscheduled_item_still_counts.

    given_transfer(
      iv_ebeln     = 'STO-000006'
      iv_menge     = '7'
      iv_scheduled = abap_false ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-quantity
      exp = '7'
      msg = 'an ordered item with no schedule line is still ordered' ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_demand[ 1 ]-req_date
      msg = 'and it has no committed date, which means as soon as possible' ).

  ENDMETHOD.

  METHOD other_supplying_plant_is_out.

    given_transfer(
      iv_ebeln = 'STO-000007'
      iv_menge = '10'
      iv_reswk = '3000' ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open_demand(
        iv_matnr = c_matnr
        iv_werks = c_werks )
      msg = 'stock is only taken out of the plant that supplies the transfer' ).

  ENDMETHOD.

  METHOD deleted_item_is_out.

    given_transfer(
      iv_ebeln   = 'STO-000008'
      iv_menge   = '10'
      iv_deleted = abap_true ).

    cl_abap_unit_assert=>assert_initial( mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ) ).

  ENDMETHOD.

  METHOD completed_item_is_out.

    given_transfer(
      iv_ebeln    = 'STO-000009'
      iv_menge    = '10'
      iv_complete = abap_true ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open_demand(
        iv_matnr = c_matnr
        iv_werks = c_werks )
      msg = 'an item flagged as delivered is closed whatever the quantities say' ).

  ENDMETHOD.

  METHOD order_unit_becomes_base_unit.

    given_transfer(
      iv_ebeln = 'STO-000010'
      iv_menge = '3'
      iv_meins = 'CAR' ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-quantity
      exp = '36'
      msg = 'three cartons of twelve compete for thirty six pieces of stock' ).

  ENDMETHOD.

  METHOD priority_is_the_one_given.

    DATA(lo_cut) = NEW zcl_sto_demand_reader(
      io_converter = NEW zcl_unit_converter( )
      iv_priority  = '03' ).

    given_transfer(
      iv_ebeln = 'STO-000011'
      iv_menge = '10' ).

    DATA(lt_demand) = lo_cut->zif_demand_reader~read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-priority
      exp = '03'
      msg = 'where transfers rank is the callers decision' ).

  ENDMETHOD.

  METHOD lists_materials_with_demand.

    given_transfer(
      iv_ebeln = 'STO-000012'
      iv_menge = '10' ).

    given_transfer(
      iv_ebeln = 'STO-000013'
      iv_menge = '4'
      iv_matnr = c_matnr_2 ).

    given_transfer(
      iv_ebeln = 'STO-000014'
      iv_menge = '4'
      iv_reswk = '3000' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->materials_with_demand( c_werks )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( c_matnr ) ( c_matnr_2 ) ) ).

  ENDMETHOD.

ENDCLASS.
