CLASS zcl_alloc_sto_proposal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_location,
             location  TYPE string,
             stock     TYPE i,
             min_level TYPE i,
             max_level TYPE i,
           END OF ty_location.
    TYPES ty_location_tt TYPE STANDARD TABLE OF ty_location WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_surplus,
             location TYPE string,
             amount   TYPE i,
           END OF ty_surplus.
    TYPES ty_surplus_tt TYPE STANDARD TABLE OF ty_surplus WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_proposal,
             from_location TYPE string,
             to_location   TYPE string,
             quantity      TYPE i,
           END OF ty_proposal.
    TYPES ty_proposal_tt TYPE STANDARD TABLE OF ty_proposal WITH DEFAULT KEY.

    METHODS propose
      IMPORTING
        it_locations       TYPE ty_location_tt
      RETURNING
        VALUE(rt_proposal) TYPE ty_proposal_tt.

ENDCLASS.


CLASS zcl_alloc_sto_proposal IMPLEMENTATION.

  METHOD propose.
    DATA lt_surplus TYPE ty_surplus_tt.
    DATA lv_need    TYPE i.
    DATA lv_move    TYPE i.
    DATA ls_prop    TYPE ty_proposal.
    DATA lv_rest    TYPE i.
    DATA ls_surplus TYPE ty_surplus.

    " Everything above the maximum level is a surplus, everything below the
    " minimum level is a deficit.
    LOOP AT it_locations INTO DATA(ls_location).
      IF ls_location-stock > ls_location-max_level.
        CLEAR ls_surplus.
        ls_surplus-location = ls_location-location.
        ls_surplus-amount = ls_location-stock - ls_location-max_level.
        APPEND ls_surplus TO lt_surplus.
      ENDIF.
    ENDLOOP.

    LOOP AT it_locations INTO DATA(ls_deficit).
      IF ls_deficit-stock >= ls_deficit-min_level.
        CONTINUE.
      ENDIF.

      lv_need = ls_deficit-min_level - ls_deficit-stock.

      LOOP AT lt_surplus ASSIGNING FIELD-SYMBOL(<ls_surplus>).
        IF lv_need <= 0.
          EXIT.
        ENDIF.
        IF <ls_surplus>-amount <= 0.
          CONTINUE.
        ENDIF.

        " A location is never asked to ship more than it has spare, so the same
        " surplus can feed several deficits.
        IF <ls_surplus>-amount < lv_need.
          lv_move = <ls_surplus>-amount.
        ELSE.
          lv_move = lv_need.
        ENDIF.

        lv_rest = <ls_surplus>-amount - lv_move.
        <ls_surplus>-amount = lv_rest.

        CLEAR ls_prop.
        ls_prop-from_location = <ls_surplus>-location.
        ls_prop-to_location = ls_deficit-location.
        ls_prop-quantity = lv_move.
        APPEND ls_prop TO rt_proposal.

        lv_need = lv_need - lv_move.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
