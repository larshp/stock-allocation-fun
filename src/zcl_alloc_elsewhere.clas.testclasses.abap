"! Answers with a fixed set of recorded lines.
CLASS lcl_store_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_store.

    METHODS constructor
      IMPORTING
        it_recorded TYPE zif_allocation_store=>ty_recorded_tab.

  PRIVATE SECTION.
    DATA mt_recorded TYPE zif_allocation_store=>ty_recorded_tab.
    DATA mv_written  TYPE abap_bool.

ENDCLASS.


CLASS lcl_store_double IMPLEMENTATION.

  METHOD constructor.
    mt_recorded = it_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~latest_per_material.

    LOOP AT mt_recorded INTO DATA(ls_recorded).
      IF iv_matnr IS NOT INITIAL AND ls_recorded-matnr <> iv_matnr.
        CONTINUE.
      ENDIF.
      APPEND ls_recorded TO rt_recorded.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_allocation_store~save.
    " a list only reads
    CLEAR mv_written.
  ENDMETHOD.

  METHOD zif_allocation_store~read.
    CLEAR rt_allocation.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_recorded_before.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_of_material.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~record_reservation.
    CLEAR mv_written.
  ENDMETHOD.

  METHOD zif_allocation_store~delete_run.
    CLEAR mv_written.
  ENDMETHOD.

ENDCLASS.


"! Allows the plants it was told to allow, and refuses the rest.
CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    TYPES ty_werks_tab TYPE STANDARD TABLE OF mard-werks WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        it_allowed TYPE ty_werks_tab.

    METHODS asked
      RETURNING
        VALUE(rv_asked) TYPE i.

  PRIVATE SECTION.
    DATA mt_allowed TYPE ty_werks_tab.
    DATA mv_asked   TYPE i.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD constructor.
    mt_allowed = it_allowed.
  ENDMETHOD.

  METHOD asked.
    rv_asked = mv_asked.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.

    mv_asked = mv_asked + 1.

    IF NOT line_exists( mt_allowed[ table_line = iv_werks ] ).
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>not_authorised
        mv_message = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


"! Hands out what it was told, per plant.
CLASS lcl_supply_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    TYPES:
      BEGIN OF ty_row,
        matnr      TYPE mard-matnr,
        werks      TYPE mard-werks,
        avail_date TYPE d,
        quantity   TYPE zif_allocation=>ty_quantity,
      END OF ty_row.
    TYPES ty_row_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        it_row TYPE ty_row_tab.

  PRIVATE SECTION.
    DATA mt_row TYPE ty_row_tab.

ENDCLASS.


CLASS lcl_supply_double IMPLEMENTATION.

  METHOD constructor.
    mt_row = it_row.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.

    LOOP AT mt_row INTO DATA(ls_row)
        WHERE matnr = iv_matnr
          AND werks = iv_werks.
      APPEND VALUE #(
        avail_date = ls_row-avail_date
        quantity   = ls_row-quantity ) TO rt_supply.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_elsewhere DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'ELSEWHERE-01'.
    CONSTANTS c_here  TYPE mard-werks VALUE '1000'.
    CONSTANTS c_there TYPE mard-werks VALUE '2000'.
    CONSTANTS c_far   TYPE mard-werks VALUE '3000'.

    DATA mo_authority TYPE REF TO lcl_authority_double.

    METHODS setup.
    METHODS teardown.

    METHODS list_of
      IMPORTING
        it_supply      TYPE lcl_supply_double=>ty_row_tab
        it_allowed     TYPE lcl_authority_double=>ty_werks_tab
        iv_short       TYPE zif_allocation=>ty_quantity DEFAULT '40'
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_elsewhere=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS found
      IMPORTING
        it_line         TYPE zcl_alloc_elsewhere=>ty_line_tab
        iv_pattern      TYPE string
      RETURNING
        VALUE(rv_found) TYPE abap_bool.

    METHODS another_plant_is_listed FOR TESTING RAISING cx_static_check.
    METHODS the_asking_plant_is_not FOR TESTING RAISING cx_static_check.
    METHODS an_empty_plant_is_left_out FOR TESTING RAISING cx_static_check.
    METHODS a_plant_nobody_may_see FOR TESTING RAISING cx_static_check.
    METHODS covers_stops_at_the_shortfall FOR TESTING RAISING cx_static_check.
    METHODS coming_stock_is_its_own_column FOR TESTING RAISING cx_static_check.
    METHODS nothing_short_says_so FOR TESTING RAISING cx_static_check.
    METHODS nobody_else_has_it_is_quiet FOR TESTING RAISING cx_static_check.
    METHODS a_plant_is_checked_once FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_elsewhere IMPLEMENTATION.

  METHOD setup.

    DATA lt_marc TYPE STANDARD TABLE OF marc WITH EMPTY KEY.

    " the material is extended to three plants, one of which has it flagged
    " for deletion and is therefore nowhere to move goods from
    lt_marc = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr werks = c_here )
      ( mandt = sy-mandt matnr = c_matnr werks = c_there )
      ( mandt = sy-mandt matnr = c_matnr werks = c_far ) ).

    INSERT marc FROM TABLE @lt_marc.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM marc WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD list_of.

    mo_authority = NEW lcl_authority_double( it_allowed ).

    DATA(lo_cut) = NEW zcl_alloc_elsewhere(
      io_supply    = NEW lcl_supply_double( it_supply )
      io_store     = NEW lcl_store_double( VALUE #(
        ( matnr = c_matnr demand_id = 'D1' requested = iv_short
          confirmed = 0 shortfall = iv_short reason = 'S' ) ) )
      io_authority = mo_authority ).

    rt_line = lo_cut->run( c_here ).

  ENDMETHOD.

  METHOD found.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CP iv_pattern.
        rv_found = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD another_plant_is_listed.

    DATA(lt_line) = list_of(
      it_supply  = VALUE #( ( matnr = c_matnr werks = c_there quantity = '25' ) )
      it_allowed = VALUE #( ( c_here ) ( c_there ) ( c_far ) ) ).

    cl_abap_unit_assert=>assert_true(
      act = found( it_line    = lt_line
                   iv_pattern = '*2000*25*' )
      msg = 'a plant sitting on the material is the answer to the question' ).

  ENDMETHOD.

  METHOD the_asking_plant_is_not.

    " the plant that is short is not somewhere else to look, however much it
    " has left in a location it does not allocate from
    DATA(lt_line) = list_of(
      it_supply  = VALUE #(
        ( matnr = c_matnr werks = c_here quantity = '99' )
        ( matnr = c_matnr werks = c_there quantity = '25' ) )
      it_allowed = VALUE #( ( c_here ) ( c_there ) ( c_far ) ) ).

    cl_abap_unit_assert=>assert_false( found( it_line    = lt_line
                                              iv_pattern = '*99*' ) ).

  ENDMETHOD.

  METHOD an_empty_plant_is_left_out.

    DATA(lt_line) = list_of(
      it_supply  = VALUE #( ( matnr = c_matnr werks = c_there quantity = '25' ) )
      it_allowed = VALUE #( ( c_here ) ( c_there ) ( c_far ) ) ).

    cl_abap_unit_assert=>assert_false( found( it_line    = lt_line
                                              iv_pattern = '*3000*' ) ).

  ENDMETHOD.

  METHOD a_plant_nobody_may_see.

    " a user allowed to see the plant that is short is not thereby allowed to
    " see the rest of the company, and the answer is silence rather than a
    " refusal: the question was about this plant
    DATA(lt_line) = list_of(
      it_supply  = VALUE #(
        ( matnr = c_matnr werks = c_there quantity = '25' )
        ( matnr = c_matnr werks = c_far quantity = '99' ) )
      it_allowed = VALUE #( ( c_here ) ( c_there ) ) ).

    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = '*2000*25*' ) ).
    cl_abap_unit_assert=>assert_false( found( it_line    = lt_line
                                              iv_pattern = '*3000*' ) ).

  ENDMETHOD.

  METHOD covers_stops_at_the_shortfall.

    " a plant with more than is missing covers what is missing, not its whole
    " shelf: the number is what this would fix, not what that plant has
    DATA(lt_line) = list_of(
      it_supply  = VALUE #( ( matnr = c_matnr werks = c_there quantity = '100' ) )
      it_allowed = VALUE #( ( c_here ) ( c_there ) ( c_far ) )
      iv_short   = '40' ).

    cl_abap_unit_assert=>assert_true( found(
      it_line    = lt_line
      iv_pattern = '*100.000*40.000*' ) ).

  ENDMETHOD.

  METHOD coming_stock_is_its_own_column.

    " stock that is not there yet could still be transferred, and is not the
    " same offer as stock on the shelf
    DATA(lt_line) = list_of(
      it_supply  = VALUE #(
        ( matnr = c_matnr werks = c_there quantity = '10' )
        ( matnr = c_matnr werks = c_there avail_date = '20260401' quantity = '15' ) )
      it_allowed = VALUE #( ( c_here ) ( c_there ) ( c_far ) ) ).

    cl_abap_unit_assert=>assert_true( found(
      it_line    = lt_line
      iv_pattern = '*2000*10.000*15.000*25.000*' ) ).

  ENDMETHOD.

  METHOD nothing_short_says_so.

    mo_authority = NEW lcl_authority_double( VALUE #( ( c_here ) ) ).

    DATA(lo_cut) = NEW zcl_alloc_elsewhere(
      io_supply    = NEW lcl_supply_double( VALUE #( ) )
      io_store     = NEW lcl_store_double( VALUE #(
        ( matnr = c_matnr demand_id = 'D1' requested = '10'
          confirmed = '10' shortfall = 0 ) ) )
      io_authority = mo_authority ).

    DATA(lt_line) = lo_cut->run( c_here ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*Nothing was short*' ).

  ENDMETHOD.

  METHOD nobody_else_has_it_is_quiet.

    " a material nobody else has must not head an empty block: the same rule
    " features 81, 150 and 154 settled for the pages that came before
    DATA(lt_line) = list_of(
      it_supply  = VALUE #( )
      it_allowed = VALUE #( ( c_here ) ( c_there ) ( c_far ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_line )
      exp = 1
      msg = 'the heading of the page and nothing else' ).

  ENDMETHOD.

  METHOD a_plant_is_checked_once.

    list_of(
      it_supply  = VALUE #( ( matnr = c_matnr werks = c_there quantity = '25' ) )
      it_allowed = VALUE #( ( c_here ) ( c_there ) ( c_far ) ) ).

    " the plant that is short, plus each of the two others exactly once. A
    " plant asked about per material would be an authority check per material.
    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->asked( )
      exp = 3 ).

  ENDMETHOD.

ENDCLASS.
