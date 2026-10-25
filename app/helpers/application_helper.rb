module ApplicationHelper
  def remaining_sla_text(ticket)
    return "Çözüldü (#{ticket.resolved_at&.strftime('%d.%m.%Y %H:%M') || 'Tamamlandı'})" if ticket.status.to_s.downcase.in?(%w[solved resolved])
    return "SLA tanımlanmadı" if ticket.sla_deadline.nil?

    diff_seconds = (ticket.sla_deadline - Time.current).to_i

    if diff_seconds < 0
      overdue_minutes = (diff_seconds.abs / 60.0).ceil
      if overdue_minutes >= 60
        "İhlal Edildi (#{overdue_minutes / 60} sa #{overdue_minutes % 60} dk gecikti)"
      else
        "İhlal Edildi (#{overdue_minutes} dk gecikti)"
      end
    else
      remaining_minutes = (diff_seconds / 60.0).ceil
      if remaining_minutes >= 60
        hours = remaining_minutes / 60
        mins = remaining_minutes % 60
        mins > 0 ? "Kalan: #{hours} saat #{mins} dk" : "Kalan: #{hours} saat"
      else
        "Kalan: #{remaining_minutes} dk"
      end
    end
  end

  def sla_badge_classes(ticket)
    if ticket.status.to_s.downcase.in?(%w[solved resolved])
      "bg-emerald-950/60 text-emerald-400 border border-emerald-800/50 font-medium"
    elsif ticket.sla_breached?
      "bg-red-950/60 text-red-400 border border-red-800/50 font-semibold"
    elsif ticket.sla_deadline.present? && (ticket.sla_deadline - Time.current) <= 1.hour
      "bg-amber-950/60 text-amber-400 border border-amber-800/50 font-medium"
    else
      "bg-zinc-800/80 text-zinc-300 border border-zinc-700/60 font-medium"
    end
  end

  def status_badge_classes(status)
    case status.to_s.downcase
    when "new"
      "bg-cyan-950/60 text-cyan-400 border border-cyan-800/50"
    when "open", "in progress"
      "bg-amber-950/60 text-amber-400 border border-amber-800/50"
    when "solved", "resolved"
      "bg-emerald-950/60 text-emerald-400 border border-emerald-800/50"
    else
      "bg-zinc-800 text-zinc-300 border border-zinc-700"
    end
  end

  def status_dot_classes(status)
    case status.to_s.downcase
    when "new" then "bg-cyan-400"
    when "open", "in progress" then "bg-amber-400"
    when "solved", "resolved" then "bg-emerald-400"
    else "bg-zinc-400"
    end
  end

  def status_label(status)
    case status.to_s.downcase
    when "new" then "Yeni (New)"
    when "open" then "Açık (Open)"
    when "in progress" then "İncelemede (In Progress)"
    when "solved", "resolved" then "Çözüldü (Resolved)"
    else status.to_s.titleize
    end
  end

  def priority_badge_classes(priority)
    case priority.to_s.downcase
    when "urgent", "critical"
      "bg-red-950/60 text-red-400 border border-red-800/50 font-semibold"
    when "high"
      "bg-orange-950/60 text-orange-400 border border-orange-800/50 font-semibold"
    when "medium", "normal"
      "bg-sky-950/60 text-sky-400 border border-sky-800/50 font-medium"
    when "low"
      "bg-zinc-800/80 text-zinc-300 border border-zinc-700/60 font-medium"
    else
      "bg-zinc-800 text-zinc-300 border border-zinc-700"
    end
  end

  def priority_dot_classes(priority)
    case priority.to_s.downcase
    when "urgent", "critical" then "bg-red-400 animate-pulse"
    when "high" then "bg-orange-400"
    when "medium", "normal" then "bg-sky-400"
    when "low" then "bg-zinc-400"
    else "bg-zinc-400"
    end
  end

  def priority_label(priority)
    case priority.to_s.downcase
    when "critical" then "Kritik (Critical)"
    when "urgent" then "Acil (Urgent)"
    when "high" then "Yüksek (High)"
    when "medium" then "Orta (Medium)"
    when "normal" then "Normal"
    when "low" then "Düşük (Low)"
    else priority.to_s.titleize
    end
  end
end
