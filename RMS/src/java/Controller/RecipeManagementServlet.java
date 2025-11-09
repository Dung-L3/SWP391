package Controller;

import Dal.RecipeDAO;
import Dal.InventoryDAO;
import Dal.MenuDAO;
import Models.Recipe;
import Models.RecipeItem;
import Models.InventoryItem;
import Models.MenuItem;
import Models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;

/**
 * RecipeManagementServlet - Quản lý công thức món ăn (BOM)
 */
public class RecipeManagementServlet extends HttpServlet {

    private RecipeDAO recipeDAO;
    private InventoryDAO inventoryDAO;
    private MenuDAO menuDAO;

    @Override
    public void init() throws ServletException {
        recipeDAO = new RecipeDAO();
        inventoryDAO = new InventoryDAO();
        menuDAO = new MenuDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session == null) ? null : (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "edit":
                    handleEditRecipe(request, response, currentUser);
                    break;
                case "list":
                default:
                    handleListRecipes(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/RecipeManagement.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session == null) ? null : (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        try {
            switch (action) {
                case "add-ingredient":
                    handleAddIngredient(request, response, currentUser);
                    break;
                case "update-ingredient":
                    handleUpdateIngredient(request, response, currentUser);
                    break;
                case "delete-ingredient":
                    handleDeleteIngredient(request, response, currentUser);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/recipe-management");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            handleListRecipes(request, response);
        }
    }

    private boolean hasRecipePermission(User user) {
        if (user == null) return false;
        return "Manager".equalsIgnoreCase(user.getRoleName());
    }

    private void handleListRecipes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<MenuItem> menuItems = menuDAO.getMenuItems(1, 100, null, null, null, "category");

        request.setAttribute("menuItems", menuItems);
        request.setAttribute("page", "recipe");

        request.getRequestDispatcher("/views/RecipeManagement.jsp").forward(request, response);
    }

    private void handleEditRecipe(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasRecipePermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền chỉnh sửa công thức.");
            handleListRecipes(request, response);
            return;
        }

        String menuItemIdParam = request.getParameter("menuItemId");
        if (menuItemIdParam == null || menuItemIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/recipe-management");
            return;
        }

        try {
            int menuItemId = Integer.parseInt(menuItemIdParam);
            MenuItem menuItem = menuDAO.getMenuItemById(menuItemId);

            if (menuItem == null) {
                request.setAttribute("errorMessage", "Không tìm thấy món ăn.");
                handleListRecipes(request, response);
                return;
            }

            // Get or create recipe
            Recipe recipe = recipeDAO.getRecipeByMenuItemId(menuItemId);
            if (recipe == null) {
                // Create new recipe
                recipe = new Recipe(menuItemId, 1, true);
                int recipeId = recipeDAO.createRecipe(recipe);
                recipe.setRecipeId(recipeId);
            }

            List<RecipeItem> recipeItems = recipeDAO.getRecipeItems(recipe.getRecipeId());
            List<InventoryItem> allIngredients = inventoryDAO.getInventoryItems(1, 1000, null, null, "ACTIVE");

            request.setAttribute("menuItem", menuItem);
            request.setAttribute("recipe", recipe);
            request.setAttribute("recipeItems", recipeItems);
            request.setAttribute("allIngredients", allIngredients);
            request.setAttribute("page", "recipe");

            request.getRequestDispatcher("/views/RecipeEdit.jsp").forward(request, response);

        } catch (NumberFormatException nfe) {
            response.sendRedirect(request.getContextPath() + "/recipe-management");
        }
    }

    private void handleAddIngredient(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        if (!hasRecipePermission(currentUser)) {
            out.print("{\"error\":\"Không có quyền\"}");
            return;
        }

        try {
            int recipeId = Integer.parseInt(request.getParameter("recipeId"));
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            BigDecimal qty = new BigDecimal(request.getParameter("qty"));

            RecipeItem recipeItem = new RecipeItem(recipeId, itemId, qty);
            boolean success = recipeDAO.addRecipeItem(recipeItem);

            if (success) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"error\":\"Không thể thêm nguyên liệu\"}");
            }

        } catch (Exception e) {
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    private void handleUpdateIngredient(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        if (!hasRecipePermission(currentUser)) {
            out.print("{\"error\":\"Không có quyền\"}");
            return;
        }

        try {
            int recipeItemId = Integer.parseInt(request.getParameter("recipeItemId"));
            BigDecimal newQty = new BigDecimal(request.getParameter("qty"));

            boolean success = recipeDAO.updateRecipeItem(recipeItemId, newQty);

            if (success) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"error\":\"Không thể cập nhật\"}");
            }

        } catch (Exception e) {
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    private void handleDeleteIngredient(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        if (!hasRecipePermission(currentUser)) {
            out.print("{\"error\":\"Không có quyền\"}");
            return;
        }

        try {
            int recipeItemId = Integer.parseInt(request.getParameter("recipeItemId"));

            boolean success = recipeDAO.deleteRecipeItem(recipeItemId);

            if (success) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"error\":\"Không thể xóa\"}");
            }

        } catch (Exception e) {
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}

