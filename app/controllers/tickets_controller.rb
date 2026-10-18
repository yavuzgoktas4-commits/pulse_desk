class TicketsController < ApplicationController
  before_action :set_ticket, only: %i[show mark_as_open mark_as_solved]

  def index
    if params[:seed] == "force"
      Rails.application.load_seed
      return redirect_to root_path, notice: "Örnek B2B SaaS destek biletleri başarıyla yüklendi."
    end

    Rails.application.load_seed if !Rails.env.test? && Ticket.count.zero?

    @tickets = Ticket.order(created_at: :desc)
    @tickets = @tickets.where(status: params[:status]) if params[:status].present? && Ticket::STATUSES.include?(params[:status])
    @tickets = @tickets.where(priority: params[:priority]) if params[:priority].present? && Ticket::PRIORITIES.include?(params[:priority])
  end

  def show
  end

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(ticket_params)

    if @ticket.save
      redirect_to @ticket, notice: "Bilet başarıyla oluşturuldu (#{@ticket.priority.upcase} öncelik atandı)."
    else
      flash.now[:alert] = "Bilet oluşturulurken lütfen zorunlu alanları kontrol edin."
      render :new, status: :unprocessable_entity
    end
  end

  def mark_as_open
    @ticket.mark_as_open!
    redirect_to @ticket, notice: "Bilet durumu 'İncelemede (Open)' olarak güncellendi."
  end

  def mark_as_solved
    @ticket.mark_as_solved!
    redirect_to @ticket, notice: "Bilet başarıyla 'Çözüldü (Solved)' olarak işaretlendi."
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:title, :description, :customer_email)
  end
end
