module ApplicationHelper
  def remaining_sla_text(ticket)
    return "Çözüldü (#{ticket.resolved_at&.strftime('%d.%m.%Y %H:%M') || 'Tamamlandı'})" if ticket.status == "solved"
    return "SLA tanımlanmadı" if ticket.sla_deadline.nil?

    diff_seconds = (ticket.sla_deadline - Time.current).to_i

    if diff_seconds < 0
      overdue_minutes = (diff_seconds.abs / 60.0).ceil
      if overdue_minutes >= 60
        "#{overdue_minutes / 60} sa #{overdue_minutes % 60} dk gecikti"
      else
        "#{overdue_minutes} dk gecikti"
      end
    else
      remaining_minutes = (diff_seconds / 60.0).ceil
      if remaining_minutes >= 60
        "#{remaining_minutes / 60} sa #{remaining_minutes % 60} dk kaldı"
      else
        "#{remaining_minutes} dk kaldı"
      end
    end
  end

  def status_badge_classes(status)
    case status
    when "new"
      "bg-blue-50 text-blue-700 ring-1 ring-inset ring-blue-600/20"
    when "open"
      "bg-amber-50 text-amber-800 ring-1 ring-inset ring-amber-600/20"
    when "solved"
      "bg-emerald-50 text-emerald-700 ring-1 ring-inset ring-emerald-600/20"
    else
      "bg-slate-100 text-slate-700"
    end
  end

  def status_label(status)
    case status
    when "new" then "Yeni (New)"
    when "open" then "İncelemede (Open)"
    when "solved" then "Çözüldü (Solved)"
    else status.to_s.titleize
    end
  end

  def priority_badge_classes(priority)
    case priority
    when "urgent"
      "bg-rose-100 text-rose-800 ring-1 ring-inset ring-rose-600/30 font-semibold"
    when "high"
      "bg-orange-100 text-orange-800 ring-1 ring-inset ring-orange-600/30 font-semibold"
    when "medium", "normal"
      "bg-indigo-50 text-indigo-700 ring-1 ring-inset ring-indigo-600/20"
    when "low"
      "bg-slate-100 text-slate-600 ring-1 ring-inset ring-slate-500/20"
    else
      "bg-slate-100 text-slate-700"
    end
  end

  def priority_label(priority)
    case priority
    when "urgent" then "Acil (Urgent)"
    when "high" then "Yüksek (High)"
    when "medium" then "Orta (Medium)"
    when "normal" then "Normal"
    when "low" then "Düşük (Low)"
    else priority.to_s.titleize
    end
  end
end
