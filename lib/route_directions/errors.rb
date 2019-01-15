module RouteDirections
  class OverQueryLimitError < StandardError
  end

  class NoResultsError < StandardError
  end

  class DeniedQueryError < StandardError
  end
end
