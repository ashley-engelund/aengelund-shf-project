#!/usr/bin/ruby

module Adapters

  #--------------------------
  #
  # @class PaymentCoveringYearToCsvAdapter
  #
  # @desc Responsibility: Takes a Payment and creates (adapts it to) CSV including
  #  information about what part (percent) of the year it covers.
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2020-02-20
  #
  #
  #--------------------------
  class PaymentCoveringYearToCsvAdapter < AbstractAdapter


    def target_class
      CsvRow
    end


    def set_target_attributes(target)
      co_name = ''
      co_num = ''
      amount = 0

      payment_covering_year = @adaptee
      payment = @adaptee.payment

      target << payment.id
      target << quote(payment.user.full_name)
      target << payment.user.email

      if payment.payment_type == Payment::PAYMENT_TYPE_BRANDING
        co_name = payment.company.name
        co_num = payment.company.company_number
        amount = SHF_BRANDING_FEE / 100
      else
        amount = SHF_MEMBER_FEE / 100
      end

      target << payment.payment_type

      target << amount
      target << quote(payment.start_date)
      target << quote(payment.expire_date)

      target << payment_covering_year.total_number_of_days_paid
      target << payment_covering_year.sek_per_day

      target << payment_covering_year.num_days_of_year_covered
      target << payment_covering_year.days_paid_for_year

      target << quote(payment.created_at.strftime('%F'))

      target << quote(co_name)
      target << co_num

      target << payment.status
      target << payment.hips_id

      target << quote(payment.notes)

      target
    end


  end

end
